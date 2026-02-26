import streamlit as st
import mysql.connector
import pandas as pd

# -----------------------------
# ⚙️ MySQL Connection
# -----------------------------
def get_connection():
    return mysql.connector.connect(
        host="localhost",        # ⬅️ change if needed
        user="root",             # ⬅️ change if needed
        password="",             # ⬅️ change to your password
        database="F1"
    )

# -----------------------------
# 🧾 Utility: Fetch SQL as DataFrame
# -----------------------------
def run_query(query, params=None):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query, params or ())
        rows = cursor.fetchall()
        df = pd.DataFrame(rows)
        cursor.close()
        conn.close()
        return df
    except mysql.connector.Error as e:
        cursor.close()
        conn.close()
        st.error(f"❌ SQL Error: {e.msg}")
        return pd.DataFrame()

# -----------------------------
# 📦 Stored Procedures
# -----------------------------
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
# 🧩 Session State Initialization
# -----------------------------
if "results_df" not in st.session_state:
    st.session_state["results_df"] = pd.DataFrame()

# -----------------------------
# 🧩 Utility to refresh Results table
# -----------------------------
def refresh_results_table():
    df = run_query("""
        SELECT r.Race_ID,
               getDriverFullName(r.Driver_ID) AS Driver,
               r.Constructor_ID, r.Car_ID,
               r.Position_Order, r.Grid, r.Points, r.Status_ID, r.RaceRank
        FROM Results r
        ORDER BY Race_ID, Position_Order;
    """)
    st.session_state["results_df"] = df
    return df

# -----------------------------
# 🧩 UI Setup
# -----------------------------
st.set_page_config(page_title="F1 Database Dashboard", layout="wide")

st.sidebar.title("🏎️ F1 Database Dashboard")
section = st.sidebar.radio("Select Section", [
    "Results",
    "Results Manipulation",
    "Drivers",
    "Constructors",
    "Races",
    "Cars",
    "Status",
    "WDC",
    "WCC", 
    "Nested Query",
    "Admin Options"
])

st.title(f"📘 {section}")

# -----------------------------
# 🔍 Results Section
# -----------------------------
if section == "Results":
    st.subheader("Race Results")
    df = refresh_results_table()
    if df.empty:
        st.warning("No results found in database.")
    else:
        st.dataframe(df)

# -----------------------------
# ⚙️ Results Manipulation Section
# -----------------------------
elif section == "Results Manipulation":
    st.subheader("🧩 Manage Results")

    st.markdown("### ➕ Add New Result")
    with st.form("add_result_form"):
        race_id = st.number_input("Race ID", min_value=1)
        driver_id = st.number_input("Driver ID", min_value=1)
        constructor_id = st.number_input("Constructor ID", min_value=1)
        car_id = st.number_input("Car ID", min_value=1)
        pos_order = st.number_input("Position Order", min_value=1)
        grid = st.number_input("Grid", min_value=1)
        status_id = st.number_input("Status ID", min_value=1)
        submitted = st.form_submit_button("Add Result")

        if submitted:
            call_procedure("add_result", [race_id, driver_id, constructor_id, car_id, pos_order, grid, status_id])
            st.success("✅ Result added successfully!")
            df = refresh_results_table()
            st.dataframe(df)

    st.divider()

    st.markdown("### ⭐ Assign Points for Race")
    race_for_points = st.number_input("Race ID for Points Assignment", min_value=1, key="points_race")
    if st.button("Assign Points"):
        call_procedure("assign_points_for_race", [race_for_points])
        st.success(f"⭐ Points assigned successfully for Race {race_for_points}!")
        df = refresh_results_table()
        st.dataframe(df)

    st.divider()

    st.markdown("### 🔄 Swap Finishing Positions")
    col1, col2, col3 = st.columns(3)
    with col1:
        race_id_swap = st.number_input("Race ID", min_value=1, key="swap_race")
    with col2:
        driver1 = st.number_input("Driver 1 ID", min_value=1, key="d1")
    with col3:
        driver2 = st.number_input("Driver 2 ID", min_value=1, key="d2")
    if st.button("Swap Positions"):
        call_procedure("swap_driver_positions", [race_id_swap, driver1, driver2])
        st.success("🔁 Swapped successfully!")
        df = refresh_results_table()
        st.dataframe(df)

    st.divider()

    st.markdown("### 🗑️ Delete Result")
    with st.form("delete_result_form"):
        del_race_id = st.number_input("Race ID", min_value=1, key="del_race")
        del_driver_id = st.number_input("Driver ID", min_value=1, key="del_driver")
        del_posi_ord = st.number_input("Position Order", min_value=1, key="del_posi")
        del_submit = st.form_submit_button("Delete Result")

        if del_submit:
            call_procedure("delete_result", [del_race_id, del_driver_id, del_posi_ord])
            st.success("🗑️ Result deleted successfully!")
            df = refresh_results_table()
            st.dataframe(df)

    st.divider()

    st.markdown("### 🏁 Recalculate All Race Ranks")
    if st.button("Recalculate Race Ranks"):
        call_procedure("RecalculateAllRaceRanks")
        st.success("✅ Race ranks recalculated successfully!")
        df = refresh_results_table()
        st.dataframe(df)

# -----------------------------
# 👨‍✈️ Drivers Section
# -----------------------------
elif section == "Drivers":
    st.subheader("Driver Information")
    df = run_query("SELECT * FROM Drivers;")
    st.dataframe(df)

# -----------------------------
# 🏗️ Constructors Section
# -----------------------------
elif section == "Constructors":
    st.subheader("Constructors")
    df = run_query("SELECT * FROM Constructors;")
    st.dataframe(df)

# -----------------------------
# 🏁 Races Section
# -----------------------------
elif section == "Races":
    st.subheader("Races Overview")
    df = run_query("""
        SELECT r.Race_ID, r.Year, g.GP_Name, c.C_Name AS Circuit, c.Country, r.Laps
        FROM Races r
        JOIN GPs g ON r.GP_ID = g.GP_ID
        JOIN Circuits c ON r.Circuit_ID = c.Circuit_ID;
    """)
    st.dataframe(df)

# -----------------------------
# 🚗 Cars Section
# -----------------------------
elif section == "Cars":
    st.subheader("Cars")
    df = run_query("""
        SELECT c.Car_ID, c.Engine, c.Tyres, con.Con_Name AS Constructor
        FROM Cars c
        JOIN Constructors con ON c.Constructor_ID = con.Constructor_ID;
    """)
    st.dataframe(df)

# -----------------------------
# 🏳️ Status Section
# -----------------------------
elif section == "Status":
    st.subheader("Race Status Types")
    df = run_query("SELECT * FROM Status;")
    st.dataframe(df)

# -----------------------------
# 🏆 World Drivers Championship (WDC)
# -----------------------------
elif section == "WDC":
    st.subheader("🏆 World Drivers Championship (WDC) Standings")
    df = run_query("""
        SELECT d.Driver_ID, getDriverFullName(d.Driver_ID) AS Driver, SUM(r.Points) AS Total_Points
        FROM Results r
        JOIN Drivers d ON r.Driver_ID = d.Driver_ID
        GROUP BY d.Driver_ID
        ORDER BY Total_Points DESC;
    """)
    st.dataframe(df)

# -----------------------------
# 🏆 World Constructors Championship (WCC)
# -----------------------------
elif section == "WCC":
    st.subheader("🏆 World Constructors Championship (WCC) Standings")
    df = run_query("""
        SELECT c.Constructor_ID, c.Con_Name AS Constructor, SUM(r.Points) AS Total_Points
        FROM Results r
        JOIN Constructors c ON r.Constructor_ID = c.Constructor_ID
        GROUP BY c.Constructor_ID
        ORDER BY Total_Points DESC;
    """)
    st.dataframe(df)

# -----------------------------
# 🔍 Nested Query Section
# -----------------------------
elif section == "Nested Query":
    st.markdown("### 🔎 Nested Query: Drivers who scored points in all their races")
    if st.button("Run nested query: always-scored"):
        nested_df = run_query("""
            SELECT d.Driver_ID,
                   getDriverFullName(d.Driver_ID) AS Driver,
                   (SELECT COUNT(*) FROM Results r WHERE r.Driver_ID = d.Driver_ID) AS RacesParticipated,
                   (SELECT COUNT(*) FROM Results r WHERE r.Driver_ID = d.Driver_ID AND r.Points > 0) AS RacesWithPoints
            FROM Drivers d
            HAVING RacesParticipated = RacesWithPoints
            ORDER BY Driver;
        """)
        if nested_df.empty:
            st.info("No drivers matched the criteria.")
        else:
            st.dataframe(nested_df)

# -----------------------------
# 🔐 Admin Options Section
# -----------------------------
elif section == "Admin Options":
    st.markdown("### 🔐 Create DB User (Admin only)")
    new_user = st.text_input("New DB username")
    new_pass = st.text_input("New DB password", type="password")
    privilege = st.selectbox("Grant privilege", ["SELECT", "INSERT", "UPDATE", "DELETE", "ALL"])
    if st.button("Create user and grant privilege"):
        conn = None
        cur = None
        try:
            conn = get_connection()  # must be admin/root
            cur = conn.cursor()
            cur.execute(f"CREATE USER IF NOT EXISTS '{new_user}'@'localhost' IDENTIFIED BY %s", (new_pass,))
            cur.execute(f"GRANT {privilege} ON F1.* TO '{new_user}'@'localhost'")
            conn.commit()
            st.success("User created and privilege granted (local DB).")
        except Exception as e:
            st.error(f"Failed: {e}")
        finally:
            if cur:
                cur.close()
            if conn:
                conn.close()
