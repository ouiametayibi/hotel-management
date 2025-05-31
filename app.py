import sqlite3
import streamlit as st
from datetime import datetime

conn = sqlite3.connect("HotelDB.db", check_same_thread=False)
cur = conn.cursor()

def get_reservations():
    query = """
    SELECT R.Id_Reservation, C.Nom_complet, R.Date_arrivee, R.Date_depart
    FROM Reservation R
    JOIN Client C ON R.Id_Client = C.Id_Client
    ORDER BY R.Date_arrivee
    """
    cur.execute(query)
    return cur.fetchall()

def get_clients():
    cur.execute("SELECT * FROM Client ORDER BY Nom_complet")
    return cur.fetchall()

def get_available_rooms(date_debut, date_fin):
    query = """
    SELECT Id_Chambre, Numero, Etage, Fumeurs, Id_Type, Id_Hotel FROM Chambre
    WHERE Id_Chambre NOT IN (
        SELECT Co.Id_Chambre
        FROM Concerner Co
        JOIN Reservation R ON Co.Id_Reservation = R.Id_Reservation
        WHERE NOT (R.Date_depart < ? OR R.Date_arrivee > ?)
    )
    """
    cur.execute(query, (date_debut, date_fin))
    return cur.fetchall()

def add_client(adresse, ville, code_postal, email, telephone, nom_complet):
    cur.execute("""
        INSERT INTO Client (Adresse, Ville, Code_postal, Email, Numero_telephone, Nom_complet)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (adresse, ville, code_postal, email, telephone, nom_complet))
    conn.commit()

def add_reservation(date_arrivee, date_depart, id_client, chambres):
    cur.execute("""
        INSERT INTO Reservation (Date_arrivee, Date_depart, Id_Client)
        VALUES (?, ?, ?)
    """, (date_arrivee, date_depart, id_client))
    id_reservation = cur.lastrowid
    for chambre_id in chambres:
        cur.execute("""
            INSERT INTO Concerner (Id_Reservation, Id_Chambre)
            VALUES (?, ?)
        """, (id_reservation, chambre_id))
    conn.commit()

st.title("Gestion Hôtel - Interface")

menu = st.sidebar.selectbox("Menu", [
    "Liste des réservations",
    "Liste des clients",
    "Chambres disponibles",
    "Ajouter un client",
    "Ajouter une réservation"
])

if menu == "Liste des réservations":
    st.header("Liste des réservations")
    reservations = get_reservations()
    for res in reservations:
        st.write(f"Réservation #{res[0]} : {res[1]} du {res[2]} au {res[3]}")

elif menu == "Liste des clients":
    st.header("Liste des clients")
    clients = get_clients()
    for c in clients:
        st.write(f"{c[6]} - {c[1]}, {c[2]}, {c[3]}, Email: {c[4]}, Tel: {c[5]}")

elif menu == "Chambres disponibles":
    st.header("Chercher chambres disponibles")
    date_debut = st.date_input("Date début")
    date_fin = st.date_input("Date fin")
    if st.button("Rechercher"):
        if date_debut > date_fin:
            st.error("La date de début doit être avant la date de fin")
        else:
            chambres = get_available_rooms(date_debut.isoformat(), date_fin.isoformat())
            if chambres:
                st.write(f"Chambres disponibles entre {date_debut} et {date_fin} :")
                for ch in chambres:
                    st.write(f"Chambre #{ch[0]}, Numéro: {ch[1]}, Étage: {ch[2]}, Fumeurs: {'Oui' if ch[3] else 'Non'}, Type ID: {ch[4]}, Hôtel ID: {ch[5]}")
            else:
                st.write("Aucune chambre disponible")

elif menu == "Ajouter un client":
    st.header("Ajouter un nouveau client")
    adresse = st.text_input("Adresse")
    ville = st.text_input("Ville")
    code_postal = st.text_input("Code postal")
    email = st.text_input("Email")
    telephone = st.text_input("Numéro de téléphone")
    nom_complet = st.text_input("Nom complet")
    if st.button("Ajouter client"):
        if adresse and ville and code_postal and email and telephone and nom_complet:
            add_client(adresse, ville, code_postal, email, telephone, nom_complet)
            st.success("Client ajouté avec succès !")
        else:
            st.error("Veuillez remplir tous les champs")

elif menu == "Ajouter une réservation":
    st.header("Ajouter une réservation")
    clients = get_clients()
    client_options = {f"{c[6]} (ID:{c[0]})": c[0] for c in clients}
    client_sel = st.selectbox("Client", list(client_options.keys()))
    date_arrivee = st.date_input("Date d'arrivée")
    date_depart = st.date_input("Date de départ")
    chambres_dispos = get_available_rooms(date_arrivee.isoformat(), date_depart.isoformat())
    chambres_dict = {f"Chambre #{c[0]} Num:{c[1]} Étage:{c[2]}": c[0] for c in chambres_dispos}
    chambres_sel = st.multiselect("Chambres disponibles", list(chambres_dict.keys()))

    if st.button("Ajouter réservation"):
        if date_arrivee > date_depart:
            st.error("La date d'arrivée doit être avant la date de départ")
        elif not chambres_sel:
            st.error("Sélectionnez au moins une chambre")
        else:
            id_client = client_options[client_sel]
            chambres_ids = [chambres_dict[ch] for ch in chambres_sel]
            add_reservation(date_arrivee.isoformat(), date_depart.isoformat(), id_client, chambres_ids)
            st.success("Réservation ajoutée avec succès !")
