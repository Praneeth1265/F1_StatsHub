import streamlit as st
import mysql.connector
import pandas as pd
import os

# -----------------------------
# DATABASE CONNECTION
# -----------------------------
def get_connection():
    return mysql.connector.connect(
        host=os.environ["MYSQLHOST"],
        user=os.environ["MYSQLUSER"],
        password=os.environ["MYSQLPASSWORD"],
        database=os.environ["MYSQLDATABASE"],
        port=int(os.environ["MYSQLPORT"])
    )

def run_query(query, params=None):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params or ())
        rows = cursor.fetchall()
        df = pd.DataFrame(rows)
        return df
    except mysql.connector.Error as e:
        st.error(f"❌ SQL Error: {e.msg}")
        return pd.DataFrame()
    finally:
        cursor.close()
        conn.close()

def call_procedure(proc_name, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc(proc_name, params or ())
        conn.commit()
    except mysql.connector.Error as e:
        st.error(f"❌ Database Error: {e.msg}")
    finally:
        cursor.close()
        conn.close()

# -----------------------------
# REFRESH RESULTS TABLE
# -----------------------------
def refresh_results_table():
    df = run_query("""
        SELECT r.Race_ID,
               CONCAT_WS(' ', d.Forename, d.Surname) AS Driver,
               r.Constructor_ID, r.Car_ID,
               r.Position_Order, r.Grid, r.Points,
               r.Status_ID, r.RaceRank
        FROM Results r
        JOIN Drivers d ON r.Driver_ID = d.Driver_ID
        ORDER BY Race_ID, Position_Order;
    """)
    return df

# -----------------------------
# STREAMLIT UI
# -----------------------------
st.set_page_config(page_title="F1 Database Dashboard", layout="wide")

st.sidebar.title("🏎️ F1 Database Dashboard")
section = st.sidebar.radio("Select Section", [
    "Results",
    "Results Manipulation",
    "Drivers",
    "Constructors",
    "WDC",
    "Nested Query"
])

st.title(f"📘 {section}")

# -----------------------------
# RESULTS SECTION
# -----------------------------
if section == "Results":
    st.subheader("Race Results")
    df = refresh_results_table()
    if df.empty:
        st.warning("No results found.")
    else:
        st.dataframe(df)

# -----------------------------
# RESULTS MANIPULATION
# -----------------------------
elif section == "Results Manipulation":

    st.subheader("➕ Add Result")

    with st.form("add_result"):
        race_id = st.number_input("Race ID", min_value=1)
        driver_id = st.number_input("Driver ID", min_value=1)
        constructor_id = st.number_input("Constructor ID", min_value=1)
        car_id = st.number_input("Car ID", min_value=1)
        pos_order = st.number_input("Position Order", min_value=1)
        grid = st.number_input("Grid", min_value=1)
        status_id = st.number_input("Status ID", min_value=1)

        submitted = st.form_submit_button("Add Result")

        if submitted:

            # Points auto assignment (Trigger replacement)
            points_map = {
                1: 25, 2: 18, 3: 15, 4: 12, 5: 10,
                6: 8, 7: 6, 8: 4, 9: 2, 10: 1
            }
            points = points_map.get(pos_order, 0)

            # Duplicate check (Trigger replacement)
            duplicate = run_query("""
                SELECT 1 FROM Results
                WHERE Driver_ID = %s
                AND Constructor_ID = %s
                AND Position_Order = %s
                AND Race_ID = %s
            """, (driver_id, constructor_id, pos_order, race_id))

            if not duplicate.empty:
                st.error("❌ Duplicate entry detected!")
            else:
                conn = get_connection()
                cursor = conn.cursor()
                try:
                    cursor.execute("""
                        INSERT INTO Results
                        (Race_ID, Driver_ID, Constructor_ID, Car_ID,
                         Position_Order, Grid, Points, Status_ID)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    """, (race_id, driver_id, constructor_id, car_id,
                          pos_order, grid, points, status_id))
                    conn.commit()
                    st.success("✅ Result added successfully!")
                except mysql.connector.Error as e:
                    st.error(f"❌ Error: {e.msg}")
                finally:
                    cursor.close()
                    conn.close()

                st.dataframe(refresh_results_table())

# -----------------------------
# DRIVERS SECTION
# -----------------------------
elif section == "Drivers":

    st.subheader("Drivers")

    with st.form("add_driver"):
        driver_id = st.number_input("Driver ID", min_value=1)
        forename = st.text_input("Forename")
        surname = st.text_input("Surname")
        nationality = st.text_input("Nationality")
        submitted = st.form_submit_button("Add Driver")

        if submitted and forename and surname:
            conn = get_connection()
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    INSERT INTO Drivers (Driver_ID, Forename, Surname, Nationality)
                    VALUES (%s, %s, %s, %s)
                """, (driver_id, forename, surname, nationality))
                conn.commit()
                st.success("✅ Driver added!")
            except mysql.connector.Error as e:
                st.error(f"❌ {e.msg}")
            finally:
                cursor.close()
                conn.close()

    df = run_query("""
        SELECT Driver_ID,
               CONCAT_WS(' ', Forename, Surname) AS Driver,
               Nationality
        FROM Drivers
        ORDER BY Driver_ID;
    """)
    st.dataframe(df)

# -----------------------------
# CONSTRUCTORS
# -----------------------------
elif section == "Constructors":

    st.subheader("Constructors")

    df = run_query("""
        SELECT Constructor_ID, Con_Name, Nationality
        FROM Constructors
        ORDER BY Constructor_ID;
    """)
    st.dataframe(df)

# -----------------------------
# WDC STANDINGS
# -----------------------------
elif section == "WDC":

    st.subheader("World Drivers Championship")

    df = run_query("""
        SELECT d.Driver_ID,
               CONCAT_WS(' ', d.Forename, d.Surname) AS Driver,
               SUM(r.Points) AS Total_Points
        FROM Results r
        JOIN Drivers d ON r.Driver_ID = d.Driver_ID
        GROUP BY d.Driver_ID
        ORDER BY Total_Points DESC;
    """)
    st.dataframe(df)

# -----------------------------
# NESTED QUERY
# -----------------------------
elif section == "Nested Query":

    st.subheader("Drivers who scored in all races")

    if st.button("Run Query"):
        df = run_query("""
            SELECT d.Driver_ID,
                   CONCAT_WS(' ', d.Forename, d.Surname) AS Driver,
                   (SELECT COUNT(*) FROM Results r WHERE r.Driver_ID = d.Driver_ID) AS RacesParticipated,
                   (SELECT COUNT(*) FROM Results r WHERE r.Driver_ID = d.Driver_ID AND r.Points > 0) AS RacesWithPoints
            FROM Drivers d
            HAVING RacesParticipated = RacesWithPoints;
        """)
        st.dataframe(df)