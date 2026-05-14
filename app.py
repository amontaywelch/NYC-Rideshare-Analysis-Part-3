import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import os

# ── Page config ───────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="NYC Congestion Pricing: Uber vs Lyft",
    page_icon="🚖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ── Colors ────────────────────────────────────────────────────────────────────
UBER_COLOR = "#FFFFFF"
LYFT_COLOR = "#FF00BF"
POS_COLOR  = "#00C853"
NEG_COLOR  = "#FF1744"
BG_COLOR   = "#0E1117"
CARD_BG    = "#1E2130"

# ── Custom CSS ────────────────────────────────────────────────────────────────
st.markdown("""
<style>
    .main { background-color: #0E1117; }
    .metric-card {
        background-color: #1E2130;
        border-radius: 10px;
        padding: 20px;
        text-align: center;
        border: 1px solid #2E3250;
    }
    .metric-label { font-size: 13px; color: #8892A4; margin-bottom: 4px; }
    .metric-value { font-size: 28px; font-weight: 700; color: #FFFFFF; }
    .metric-delta-pos { font-size: 14px; color: #00C853; }
    .metric-delta-neg { font-size: 14px; color: #FF1744; }
    .section-header {
        font-size: 22px;
        font-weight: 600;
        color: #FFFFFF;
        margin-top: 30px;
        margin-bottom: 10px;
        border-left: 4px solid #FF00BF;
        padding-left: 12px;
    }
    .finding-box {
        background-color: #1E2130;
        border-radius: 8px;
        padding: 16px 20px;
        border-left: 4px solid #FF00BF;
        margin-bottom: 12px;
        color: #CDD6F4;
        font-size: 14px;
        line-height: 1.6;
    }
    .uber-badge {
        background-color: #FFFFFF;
        color: #000000;
        padding: 2px 10px;
        border-radius: 4px;
        font-weight: 700;
        font-size: 13px;
    }
    .lyft-badge {
        background-color: #FF00BF;
        color: #FFFFFF;
        padding: 2px 10px;
        border-radius: 4px;
        font-weight: 700;
        font-size: 13px;
    }
    div[data-testid="stSidebar"] { background-color: #161B2E; text-align: center; }
    div[data-testid="stSidebar"] .stRadio { text-align: left; }
    .stSelectbox label { color: #8892A4; }
    .stRadio [data-testid="stMarkdownContainer"] p { color: #CDD6F4; }
    div[data-testid="stRadio"] label:hover { color: #FF00BF; }
</style>
""", unsafe_allow_html=True)

# ── Data loader ───────────────────────────────────────────────────────────────
@st.cache_data
def load(filename):
    path = os.path.join("data", filename)
    return pd.read_csv(path)

# ── Plotly base layout ────────────────────────────────────────────────────────
def base_layout(title="", height=400):
    return dict(
        title=title,
        plot_bgcolor=BG_COLOR,
        paper_bgcolor=BG_COLOR,
        font=dict(color="#CDD6F4", family="Inter, sans-serif"),
        height=height,
        margin=dict(l=40, r=40, t=50, b=40),
        legend=dict(bgcolor=CARD_BG, bordercolor="#2E3250", borderwidth=1),
        xaxis=dict(gridcolor="#1E2130", linecolor="#2E3250"),
        yaxis=dict(gridcolor="#1E2130", linecolor="#2E3250"),
    )

def fmt_millions(val):
    if abs(val) >= 1_000_000_000:
        return f"${val/1_000_000_000:.2f}B"
    elif abs(val) >= 1_000_000:
        return f"${val/1_000_000:.1f}M"
    else:
        return f"${val:,.0f}"

def fmt_trips(val):
    if abs(val) >= 1_000_000:
        return f"{val/1_000_000:.1f}M"
    else:
        return f"{val:,.0f}"

def delta_color(val):
    return "metric-delta-pos" if val >= 0 else "metric-delta-neg"

def delta_arrow(val):
    return "▲" if val >= 0 else "▼"

def metric_card(label, value, delta=None):
    delta_html = ""
    if delta is not None:
        cls = delta_color(delta)
        delta_html = f'<div class="{cls}" style="white-space: nowrap;">{delta_arrow(delta)} {abs(delta):.1f}% vs 2024</div>'
    return f"""
    <div class="metric-card">
        <div class="metric-label">{label}</div>
        <div class="metric-value">{value}</div>
        {delta_html}
    </div>
    """

# ── Sidebar ───────────────────────────────────────────────────────────────────
with st.sidebar:
    st.markdown("<div style='text-align: center;'>", unsafe_allow_html=True)
    st.markdown("### 🚖 NYC Congestion Pricing")
    st.markdown("**Uber vs Lyft Impact Analysis**")
    st.markdown("</div>", unsafe_allow_html=True)
    st.markdown("---")
    page = st.radio(
        "Navigate",
        ["Overview", "Market Share", "Revenue & Earnings", "Behavioral Patterns", "Methodology"],
        label_visibility="collapsed"
    )
    st.markdown("---")
    st.markdown("<br>", unsafe_allow_html=True)
    st.markdown("<div style='text-align: center;'><span class='uber-badge'>Uber</span> &nbsp; <span class='lyft-badge'>Lyft</span></div>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)
    st.markdown("<p style='text-align: center; font-size: 12px; color: #8892A4;'>Data: NYC TLC · 400M+ records</p>", unsafe_allow_html=True)
    st.markdown("<p style='text-align: center; font-size: 12px; color: #8892A4;'>Congestion fee effective Jan 5, 2025</p>", unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# OVERVIEW
# ══════════════════════════════════════════════════════════════════════════════
if page == "Overview":
    st.title("NYC Congestion Zone Pricing: Uber vs Lyft")
    st.markdown("#### How the $1.50 congestion fee reshaped NYC's rideshare market in 2025")
    st.markdown("---")

    # KPI cards
    uber_trips  = load("uber_citywide_trips.csv").iloc[0]
    lyft_trips  = load("lyft_citywide_trips.csv").iloc[0]
    uber_rev    = load("uber_citywide_revenue.csv").iloc[0]
    lyft_rev    = load("lyft_citywide_revenue.csv").iloc[0]

    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.markdown(metric_card("Uber Trip Growth", fmt_trips(abs(uber_trips["trip_diff"])), uber_trips["growth_pct"]), unsafe_allow_html=True)
    with c2:
        st.markdown(metric_card("Lyft Trip Growth", fmt_trips(abs(lyft_trips["trip_diff"])), lyft_trips["growth_pct"]), unsafe_allow_html=True)
    with c3:
        st.markdown(metric_card("Uber Driver Pay", fmt_millions(uber_rev["driver_pay_2025"]), uber_rev["driver_pay_growth_pct"]), unsafe_allow_html=True)
    with c4:
        st.markdown(metric_card("Lyft Driver Pay", fmt_millions(lyft_rev["driver_pay_2025"]), lyft_rev["driver_pay_growth_pct"]), unsafe_allow_html=True)

    
    
    st.markdown("<div style='margin-top: 30px;'>Lyft completed 6.9M more trips than in 2024 while Uber shed 3.1M. Despite losing volume, Uber's driver pay still grew, but at less than one-sixth the rate of Lyft's.</div>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)

    # Monthly trend hero chart
    st.markdown('<div class="section-header">Monthly Trip Growth: The Competitive Divergence</div>', unsafe_allow_html=True)
    st.caption("Lyft was negative in January and February, then recovered in March and never looked back. By Q4, Lyft was growing 18 to 21% while Uber stayed negative almost every month. The same fee, two completely different outcomes.")

    uber_monthly = load("uber_monthly_trends.csv")
    lyft_monthly = load("lyft_monthly_trends.csv")

    month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    uber_monthly["month_name"] = uber_monthly["month"].apply(lambda x: month_names[x-1])
    lyft_monthly["month_name"] = lyft_monthly["month"].apply(lambda x: month_names[x-1])

    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=uber_monthly["month_name"], y=uber_monthly["growth_pct"],
        mode="lines+markers", name="Uber",
        line=dict(color=UBER_COLOR, width=2.5),
        marker=dict(size=7)
    ))
    fig.add_trace(go.Scatter(
        x=lyft_monthly["month_name"], y=lyft_monthly["growth_pct"],
        mode="lines+markers", name="Lyft",
        line=dict(color=LYFT_COLOR, width=2.5),
        marker=dict(size=7)
    ))
    fig.add_hline(y=0, line_dash="dash", line_color="#8892A4", line_width=1)
    fig.add_vrect(x0=-0.5, x1=0.5, fillcolor="#FF00BF", opacity=0.08,
                  annotation_text="Fee starts Jan 5th", annotation_position="top left",
                  annotation_font_color="#FF00BF")
    layout = base_layout(height=420)
    layout.update(yaxis_title="YoY Growth % vs 2024", xaxis_title="Month (2025)")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("<br>", unsafe_allow_html=True)

    # Key findings
    st.markdown('<div class="section-header">Key Findings</div>', unsafe_allow_html=True)

    findings = [
    "🏆 <b>Lyft captured the congestion zone while Uber retreated.</b> Uber's Manhattan dropoffs fell 9% while Lyft's grew 10%, a 20-point competitive swing in the same market under the same $1.50 fee. Congestion pricing didn't hurt rideshare equally. It picked a winner.",
    "💰 <b>Uber cut driver pay to protect margins. Lyft did the opposite.</b> Uber's Manhattan dropoff revenue grew 7.7% while driver pay fell 4.5%. The platform kept the upside and passed the cost to drivers. Lyft's revenue grew just 3.6% but driver pay surged 12.7%. One company optimized for profit. The other optimized for supply.",
    "🕐 <b>Uber is becoming a rush hour platform in Manhattan.</b> The only hour range where Uber grew was 5AM to 11AM, the morning commute window. Lyft grew across all 24 hours and dominated the 9AM to 5PM daytime economy. Outside of rush hour, Uber is losing the city.",
    "📅 <b>Wednesday was Uber's only winning day. Lyft won every single day.</b> Uber posted negative trip growth 6 out of 7 days citywide. Lyft had zero negative days. The congestion fee didn't just hurt Uber in the zone, it accelerated a market share erosion that showed up everywhere.",
    "🗺️ <b>The fee's impact on Uber spilled beyond the zone into Brooklyn.</b> Brooklyn sits outside the congestion boundary, yet Uber lost trips there too. Riders avoiding fares that route through the zone likely shifted to Lyft, and Brooklyn absorbed some of that displacement.",
    "📈 <b>What started as a shared shock turned into a one-sided story.</b> Uber actually outpaced Lyft in January, gaining 6.4% while Lyft shed 3.6%. By February both companies had settled near neutral. Then when March hit, Lyft accelerated and never looked back, closing Q4 at 18 to 21% year-over-year growth while Uber stayed negative every month after January.",
]
    for f in findings:
        st.markdown(f'<div class="finding-box">{f}</div>', unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# MARKET SHARE
# ══════════════════════════════════════════════════════════════════════════════
elif page == "Market Share":
    st.title("Market Share")
    st.markdown("#### Trip volume, Manhattan activity, and Congestion Zone Exposure")
    st.markdown("---")

    # Citywide trips
    st.markdown('<div class="section-header">Citywide Trip Volume: 2024 vs 2025</div>', unsafe_allow_html=True)
    st.caption("Uber's 175.9M trips still lead the market, but that volume came at a cost, down 1.7% from 2024. Lyft's 67.2M trips represent 11.5% growth, meaning Lyft added roughly twice the trips Uber lost.")

    uber_trips = load("uber_citywide_trips.csv").iloc[0]
    lyft_trips = load("lyft_citywide_trips.csv").iloc[0]

    c1, c2 = st.columns(2)
    with c1:
        st.markdown(metric_card("Uber Total Trips 2025", fmt_trips(uber_trips["total_trips_2025"]), uber_trips["growth_pct"]), unsafe_allow_html=True)
    with c2:
        st.markdown(metric_card("Lyft Total Trips 2025", fmt_trips(lyft_trips["total_trips_2025"]), lyft_trips["growth_pct"]), unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    fig = go.Figure()

    fig.add_trace(go.Bar(
        name="Uber",
        x=["2024", "2025"],
        y=[uber_trips["total_trips_2024"], uber_trips["total_trips_2025"]],
        marker_color=UBER_COLOR,
        text=[fmt_trips(uber_trips["total_trips_2024"]), fmt_trips(uber_trips["total_trips_2025"])],
        textposition="outside"
    ))
    fig.add_trace(go.Bar(
        name="Lyft",
        x=["2024", "2025"],
        y=[lyft_trips["total_trips_2024"], lyft_trips["total_trips_2025"]],
        marker_color=LYFT_COLOR,
        text=[fmt_trips(lyft_trips["total_trips_2024"]), fmt_trips(lyft_trips["total_trips_2025"])],
        textposition="outside"
    ))
    layout = base_layout(height=400)
    layout.update(barmode="group", yaxis_title="Total Trips", yaxis_tickformat=".2s")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # Manhattan pickups vs dropoffs
    st.markdown('<div class="section-header">Manhattan Activity: Pickups vs Dropoffs</div>', unsafe_allow_html=True)
    st.caption("Uber lost trips on both ends: fewer riders requesting and fewer drivers delivering. Lyft gained on both ends. The dropoff gap is the most telling: drivers actively chose to avoid the zone for Uber but not for Lyft.")
    st.caption("Pickups = rider demand entering the zone · Dropoffs = driver supply serving the zone")

    uber_pu = load("uber_manhattan_pickups.csv").iloc[0]
    uber_do = load("uber_manhattan_dropoffs.csv").iloc[0]
    lyft_pu = load("lyft_manhattan_pickups.csv").iloc[0]
    lyft_do = load("lyft_manhattan_dropoffs.csv").iloc[0]

    col1, divider, col2 = st.columns([1, 0.02, 1])

    with col1:
        st.markdown("<h5 style='text-align: center;'>Uber</h5>", unsafe_allow_html=True)
        c1, c2 = st.columns(2)
        with c1:
            st.markdown(metric_card("2025 Pickups", fmt_trips(abs(uber_pu["trip_diff"])), uber_pu["growth_pct"]), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("2025 Dropoffs", fmt_trips(abs(uber_do["trip_diff"])), uber_do["growth_pct"]), unsafe_allow_html=True)


    with divider:
        st.markdown("<div style='border-left: 1px solid #2E3250; height: 200px; margin: auto;'></div>",
            unsafe_allow_html=True
    )

    with col2:
        st.markdown("<h5 style='text-align: center;'>Lyft</h5>", unsafe_allow_html=True)
        c1, c2 = st.columns(2)
        with c1:
            st.markdown(metric_card("2025 Pickups", fmt_trips(abs(lyft_pu["trip_diff"])), lyft_pu["growth_pct"]), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("2025 Dropoffs", fmt_trips(abs(lyft_do["trip_diff"])), lyft_do["growth_pct"]), unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    fig = go.Figure()
    categories = ["Uber Pickups", "Uber Dropoffs", "Lyft Pickups", "Lyft Dropoffs"]
    growth_vals = [uber_pu["growth_pct"], uber_do["growth_pct"],
                   lyft_pu["growth_pct"], lyft_do["growth_pct"]]
    colors = [UBER_COLOR if i < 2 else LYFT_COLOR for i, v in enumerate(growth_vals)]

    fig.add_trace(go.Bar(
        x=categories, y=growth_vals,
        marker_color=colors,
        text=[f"{v:+.1f}%" for v in growth_vals],
        textposition="outside"
    ))
    fig.add_hline(y=0, line_color="#8892A4", line_width=1)
    layout = base_layout(height=380)
    layout.update(yaxis_title="Growth % vs 2024", showlegend=False)
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # Congestion zone 2025
    st.markdown('<div class="section-header">2025 Congestion Zone Snapshot</div>', unsafe_allow_html=True)
    st.caption("Uber processed 2.5x more congestion zone trips than Lyft and collected 88.9M in fees compared to Lyft's $35.2M. Despite the larger fee burden, Uber still dominated zone volume, but the issue wasn't exposure to the zone, it was what happened to driver pay inside it.")

    uber_zone = load("uber_congestion_zone_2025.csv").iloc[0]
    lyft_zone = load("lyft_congestion_zone_2025.csv").iloc[0]

    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.markdown(metric_card("Uber Zone Trips", fmt_trips(uber_zone["congestion_zone_trips"])), unsafe_allow_html=True)
    with c2:
        st.markdown(metric_card("Uber Fees Collected", fmt_millions(uber_zone["total_fees_collected"])), unsafe_allow_html=True)
    with c3:
        st.markdown(metric_card("Lyft Zone Trips", fmt_trips(lyft_zone["congestion_zone_trips"])), unsafe_allow_html=True)
    with c4:
        st.markdown(metric_card("Lyft Fees Collected", fmt_millions(lyft_zone["total_fees_collected"])), unsafe_allow_html=True)

    st.markdown("---")

    # Borough breakdown
    st.markdown('<div class="section-header">Borough Breakdown: YoY Trip Growth</div>', unsafe_allow_html=True)

    view = st.radio("View", ["Pickups", "Dropoffs"], horizontal=True)

    if view == "Pickups":
        uber_b = load("uber_borough_pickups.csv")
        lyft_b = load("lyft_borough_pickups.csv")
    else:
        uber_b = load("uber_borough_dropoffs.csv")
        lyft_b = load("lyft_borough_dropoffs.csv")

    if view == "Pickups":
        st.caption("Uber lost pickup share in Manhattan and barely held Brooklyn. Lyft grew pickups in every borough except Staten Island. The Bronx tells the biggest story: Lyft grew 20.7% there while Uber managed just 2.1%.")
    else:
        st.caption("Uber's Manhattan dropoffs fell 9% while Lyft's grew 9.7%. Drivers are deliberately choosing where to go. Brooklyn shows the spillover effect: Uber lost dropoffs there too despite it sitting outside the congestion zone. Staten Island is the one borough where Lyft struggled.")

    uber_b = uber_b[~uber_b["borough"].isin(["Unknown", "EWR"])].sort_values("borough")
    lyft_b = lyft_b[~lyft_b["borough"].isin(["Unknown", "EWR"])].sort_values("borough")

    fig = go.Figure()
    fig.add_trace(go.Bar(name="Uber", x=uber_b["borough"], y=uber_b["growth_pct"],
                         marker_color=UBER_COLOR,
                         text=[f"{v:+.1f}%" for v in uber_b["growth_pct"]],
                         textposition="outside"))
    fig.add_trace(go.Bar(name="Lyft", x=lyft_b["borough"], y=lyft_b["growth_pct"],
                         marker_color=LYFT_COLOR,
                         text=[f"{v:+.1f}%" for v in lyft_b["growth_pct"]],
                         textposition="outside"))
    fig.add_hline(y=0, line_color="#8892A4", line_width=1)
    layout = base_layout(height=420)
    layout.update(barmode="group", yaxis_title="Growth % vs 2024")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)


# ══════════════════════════════════════════════════════════════════════════════
# REVENUE & EARNINGS
# ══════════════════════════════════════════════════════════════════════════════
elif page == "Revenue & Earnings":
    st.title("Revenue & Earnings")
    st.markdown("#### How congestion pricing changed the economics for platforms and drivers")
    st.markdown("---")

    uber_rev = load("uber_citywide_revenue.csv").iloc[0]
    lyft_rev = load("lyft_citywide_revenue.csv").iloc[0]

    # Citywide KPIs
    st.markdown('<div class="section-header">Citywide Revenue: 2025 vs 2024</div>', unsafe_allow_html=True)
    st.caption("Uber's gross bookings are nearly 3x Lyft's, but Lyft grew bookings at 4x the rate (10.6% vs 2.6%). The starkest contrast is driver pay: Lyft raised driver pay 13.1% while Uber grew it just 1.9%, despite Uber collecting far more in net revenue.")

    col1, divider, col2 = st.columns([1, 0.02, 1])
    with col1:
        st.markdown("<h5 style='text-align: center;'>Uber</h5>", unsafe_allow_html=True)
        c1, c2, c3 = st.columns(3)
        with c1:
            st.markdown(metric_card("Gross Bookings", fmt_millions(uber_rev["gross_bookings_2025"]), uber_rev["gross_bookings_growth_pct"]), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("Net Revenue", fmt_millions(uber_rev["net_revenue_2025"]), uber_rev["net_revenue_growth_pct"]), unsafe_allow_html=True)
        with c3:
            st.markdown(metric_card("Driver Pay", fmt_millions(uber_rev["driver_pay_2025"]), uber_rev["driver_pay_growth_pct"]), unsafe_allow_html=True)


    with divider:
        st.markdown(
            "<div style='border-left: 1px solid #2E3250; height: 200px; margin: auto;'></div>",
            unsafe_allow_html=True
    )

    with col2:
        st.markdown("<h5 style='text-align: center;'>Lyft</h5>", unsafe_allow_html=True)
        c1, c2, c3 = st.columns(3)
        with c1:
            st.markdown(metric_card("Gross Bookings", fmt_millions(lyft_rev["gross_bookings_2025"]), lyft_rev["gross_bookings_growth_pct"]), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("Net Revenue", fmt_millions(lyft_rev["net_revenue_2025"]), lyft_rev["net_revenue_growth_pct"]), unsafe_allow_html=True)
        with c3:
            st.markdown(metric_card("Driver Pay", fmt_millions(lyft_rev["driver_pay_2025"]), lyft_rev["driver_pay_growth_pct"]), unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    # Revenue vs Driver pay divergence
    st.markdown('<div class="section-header">The Strategy Divergence: Revenue vs Driver Pay</div>', unsafe_allow_html=True)
    st.caption("Manhattan dropoff revenue growth vs driver pay growth: The key competitive insight")

    uber_do_rev = load("uber_manhattan_dropoff_revenue.csv").iloc[0]
    lyft_do_rev = load("lyft_manhattan_dropoff_revenue.csv").iloc[0]

    fig = go.Figure()
    metrics = ["Revenue Growth", "Driver Pay Growth"]
    uber_vals = [uber_do_rev["gross_bookings_growth_pct"], uber_do_rev["driver_pay_growth_pct"]]
    lyft_vals = [lyft_do_rev["gross_bookings_growth_pct"], lyft_do_rev["driver_pay_growth_pct"]]

    fig.add_trace(go.Bar(name="Uber", x=metrics, y=uber_vals,
                         marker_color=UBER_COLOR,
                         text=[f"{v:+.1f}%" for v in uber_vals],
                         textposition="outside"))
    fig.add_trace(go.Bar(name="Lyft", x=metrics, y=lyft_vals,
                         marker_color=LYFT_COLOR,
                         text=[f"{v:+.1f}%" for v in lyft_vals],
                         textposition="outside"))
    fig.add_hline(y=0, line_color="#8892A4", line_width=1)
    layout = base_layout(height=400)
    layout.update(barmode="group", yaxis_title="Growth % vs 2024",
                  title="Manhattan Dropoff: Revenue vs Driver Pay Growth")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("""
    <div class="finding-box">
    Uber's Manhattan dropoff revenue grew 7.7% while driver pay fell 4.5%. The platform kept the upside and passed the fee cost to drivers. Lyft's dropoff revenue grew just 3.6% but driver pay surged 12.7%. Lyft shared the gains with drivers, and drivers responded by staying in the zone.
    <br><br>
    <b>The result:</b> Lyft drivers kept coming into the zone. Uber drivers didn't.
    <br><br>
    Worth noting: Uber still generates significantly more net revenue overall. This wasn't a mistake, it was a deliberate choice to protect margins. Two valid strategies, two very different outcomes for market position.
    </div>
    """, unsafe_allow_html=True)

    st.markdown("---")

    # Manhattan pickup vs dropoff
    st.markdown('<div class="section-header">Manhattan Pickup vs Dropoff Revenue</div>', unsafe_allow_html=True)

    view = st.radio("Company", ["Uber", "Lyft"], horizontal=True, key="rev_view")
    if view == "Uber":
        st.caption("Uber's net revenue held up in both pickups and dropoffs, but driver pay fell on both ends. Uber was making more money while paying drivers less, in every direction through Manhattan.")
    else:
        st.caption("Lyft grew across every metric in both pickups and dropoffs. Driver pay grew faster than revenue on dropoffs, meaning Lyft's share of each trip shifted toward drivers. That's what kept drivers willing to serve the zone.")

    if view == "Uber":
        pu = load("uber_manhattan_pickup_revenue.csv").iloc[0]
        do = load("uber_manhattan_dropoff_revenue.csv").iloc[0]
        color = UBER_COLOR
    else:
        pu = load("lyft_manhattan_pickup_revenue.csv").csv if False else load("lyft_manhattan_pickup_revenue.csv").iloc[0]
        do = load("lyft_manhattan_dropoff_revenue.csv").iloc[0]
        color = LYFT_COLOR

    if view == "Lyft":
        pu = load("lyft_manhattan_pickup_revenue.csv").iloc[0]

    categories = ["Gross Bookings", "Net Revenue", "Driver Pay", "Tips"]
    pu_growth = [pu["gross_bookings_growth_pct"], pu["net_revenue_growth_pct"],
                 pu["driver_pay_growth_pct"], pu["tips_growth_pct"]]
    do_growth = [do["gross_bookings_growth_pct"], do["net_revenue_growth_pct"],
                 do["driver_pay_growth_pct"], do["tips_growth_pct"]]

    fig = go.Figure()
    fig.add_trace(go.Bar(name="Pickups", x=categories, y=pu_growth,
                         marker_color=color, opacity=0.6,
                         text=[f"{v:+.1f}%" for v in pu_growth], textposition="outside"))
    fig.add_trace(go.Bar(name="Dropoffs", x=categories, y=do_growth,
                         marker_color=color,
                         text=[f"{v:+.1f}%" for v in do_growth], textposition="outside"))
    fig.add_hline(y=0, line_color="#8892A4", line_width=1)
    layout = base_layout(height=400)
    layout.update(barmode="group", yaxis_title="Growth % vs 2024")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # Congestion fee burden
    st.markdown('<div class="section-header">Congestion Fee Burden</div>', unsafe_allow_html=True)
    st.markdown("<div style='margin-bottom: 20px;'>Both companies paid exactly the $1.50 flat fee per congestion zone trip. Uber's $88.9M total burden vs Lyft's $35.2M reflects trip volume, not fee structure. Uber simply had more exposure in the zone.</div>", unsafe_allow_html=True)

    fee = load("congestion_fee_burden.csv")
    uber_fee = fee[fee["company"] == "Uber"].iloc[0]
    lyft_fee = fee[fee["company"] == "Lyft"].iloc[0]

    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.markdown(metric_card("Uber Total Fees", fmt_millions(uber_fee["total_congestion_fees"])), unsafe_allow_html=True)
    with c2:
        st.markdown(metric_card("Uber Avg Fee/Trip", f"${uber_fee['avg_fee_per_trip']:.2f}"), unsafe_allow_html=True)
    with c3:
        st.markdown(metric_card("Lyft Total Fees", fmt_millions(lyft_fee["total_congestion_fees"])), unsafe_allow_html=True)
    with c4:
        st.markdown(metric_card("Lyft Avg Fee/Trip", f"${lyft_fee['avg_fee_per_trip']:.2f}"), unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# BEHAVIORAL PATTERNS
# ══════════════════════════════════════════════════════════════════════════════
elif page == "Behavioral Patterns":
    st.title("Behavioral Patterns")
    st.markdown("#### When, where, and how riders and drivers responded to the fee")
    st.markdown("---")

    # Hourly patterns
    st.markdown('<div class="section-header">Hourly Trip Growth</div>', unsafe_allow_html=True)
    st.caption("Uber's growth never crosses zero outside the morning commute window. Lyft stays positive every hour of the day, peaking during the 9AM–5PM daytime economy. By evening, Uber is down 5% or more while Lyft still holds gains above 5%.")

    uber_h = load("uber_hourly_patterns.csv")
    lyft_h = load("lyft_hourly_patterns.csv")

    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=uber_h["hour_of_day"], y=uber_h["growth_pct"],
        mode="lines+markers", name="Uber",
        line=dict(color=UBER_COLOR, width=2.5),
        marker=dict(size=6), fill="tozeroy",
        fillcolor="rgba(255,255,255,0.05)"
    ))
    fig.add_trace(go.Scatter(
        x=lyft_h["hour_of_day"], y=lyft_h["growth_pct"],
        mode="lines+markers", name="Lyft",
        line=dict(color=LYFT_COLOR, width=2.5),
        marker=dict(size=6), fill="tozeroy",
        fillcolor="rgba(255,0,191,0.05)"
    ))
    fig.add_hline(y=0, line_dash="dash", line_color="#8892A4", line_width=1)
    fig.add_vrect(x0=5, x1=11, fillcolor="#FFFFFF", opacity=0.04,
                  annotation_text="5–11AM", annotation_position="top",
                  annotation_font_color="#8892A4")
    layout = base_layout(height=420)
    layout.update(xaxis_title="Hour of Day", yaxis_title="Growth % vs 2024",
                  xaxis=dict(tickmode="linear", tick0=0, dtick=2,
                             gridcolor="#1E2130", linecolor="#2E3250"))
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # Day of week
    st.markdown('<div class="section-header">Day of Week Trip Growth</div>', unsafe_allow_html=True)
    st.caption("Wednesday was Uber's only positive day at +2.5%, likely propped up by midweek commuter demand. Every other day Uber shed trips, with Saturday the worst at -4.1%. Lyft's weakest day (Sunday at +7.9%) still outperformed Uber's best day by more than 5 points.")

    uber_d = load("uber_day_of_week.csv").sort_values("day_num")
    lyft_d = load("lyft_day_of_week.csv").sort_values("day_num")

    fig = go.Figure()

    fig.add_trace(go.Bar(
    name="Uber", x=uber_d["day_of_week"], y=uber_d["growth_pct"],
    marker_color=UBER_COLOR,
    text=[f"{v:+.1f}%" for v in uber_d["growth_pct"]], textposition="outside",
    opacity=0.85
))
    fig.add_trace(go.Bar(
        name="Lyft", x=lyft_d["day_of_week"], y=lyft_d["growth_pct"],
        marker_color=LYFT_COLOR,
        text=[f"{v:+.1f}%" for v in lyft_d["growth_pct"]], textposition="outside",
        opacity=0.85
    ))
    fig.add_hline(y=0, line_color="#8892A4", line_width=1)
    layout = base_layout(height=420)
    layout.update(barmode="group", yaxis_title="Growth % vs 2024")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # Monthly trends
    st.markdown('<div class="section-header">Monthly Trip Growth Trend</div>', unsafe_allow_html=True)
    st.caption("Uber started strong in January at +6.4% while Lyft was down 3.6%. Then, the tables flipped. By March, Lyft was accelerating and never looked back, closing the year at 19.5–21.6% growth. Uber finished positive only in January, October, and December, and never topped +2.2% after the fee took hold.")

    uber_m = load("uber_monthly_trends.csv")
    lyft_m = load("lyft_monthly_trends.csv")
    month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    uber_m["month_name"] = uber_m["month"].apply(lambda x: month_names[x-1])
    lyft_m["month_name"] = lyft_m["month"].apply(lambda x: month_names[x-1])

    fig = go.Figure()
    fig.add_trace(go.Bar(name="Uber", x=uber_m["month_name"], y=uber_m["growth_pct"],
                         marker_color=UBER_COLOR, opacity=1.0,
                         text=[f"{v:+.1f}%" for v in uber_m["growth_pct"]],
                         textposition="outside"))
    fig.add_trace(go.Bar(name="Lyft", x=lyft_m["month_name"], y=lyft_m["growth_pct"],
                         marker_color=LYFT_COLOR, opacity=0.8,
                         text=[f"{v:+.1f}%" for v in lyft_m["growth_pct"]],
                         textposition="outside"))
    fig.add_hline(y=0, line_color="#8892A4", line_width=1)
    layout = base_layout(height=420)
    layout.update(barmode="group", yaxis_title="Growth % vs 2024", xaxis_title="Month")
    fig.update_layout(**layout)
    st.plotly_chart(fig, use_container_width=True)

    st.markdown("---")

    # Zone trip characteristics
    st.markdown('<div class="section-header">Congestion Zone Trip Characteristics</div>', unsafe_allow_html=True)
    st.caption("Uber zone trips pay $6.43/mile vs Lyft's 5.59 (a 15% premium), yet drivers still migrated toward Lyft. The math suggests drivers found more consistent volume outside the zone worth more than higher per-mile rates inside it.")

    uber_z = load("uber_zone_trip_characteristics.csv").iloc[0]
    lyft_z = load("lyft_zone_trip_characteristics.csv").iloc[0]

    col1, divider, col2 = st.columns([1, 0.02, 1])
    with col1:
        st.markdown("<h5 style='text-align: center;'>Uber</h5>", unsafe_allow_html=True)
        c1, c2, c3 = st.columns(3)
        with c1:
            st.markdown(metric_card("Avg Miles", f"{uber_z['avg_miles']:.2f} mi"), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("Avg Minutes", f"{uber_z['avg_minutes']:.0f} min"), unsafe_allow_html=True)
        with c3:
            st.markdown(metric_card("Avg Driver Pay", f"${uber_z['avg_driver_pay']:.2f}"), unsafe_allow_html=True)

        st.markdown("<div style='margin-top: 8px;'></div>", unsafe_allow_html=True)

        c1, c2 = st.columns(2)
        with c1:
            st.markdown(metric_card("Pay Per Mile", f"${uber_z['avg_pay_per_mile']:.2f}"), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("Pay Per Minute", f"${uber_z['avg_pay_per_minute']:.2f}"), unsafe_allow_html=True)

    with divider:
        st.markdown(
            "<div style='border-left: 1px solid #2E3250; height: 300px; margin: auto;'></div>",
        unsafe_allow_html=True
    )

    with col2:
        st.markdown("<h5 style='text-align: center;'>Lyft</h5>", unsafe_allow_html=True)
        c1, c2, c3 = st.columns(3)
        with c1:
            st.markdown(metric_card("Avg Miles", f"{lyft_z['avg_miles']:.2f} mi"), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("Avg Minutes", f"{lyft_z['avg_minutes']:.0f} min"), unsafe_allow_html=True)
        with c3:
            st.markdown(metric_card("Avg Driver Pay", f"${lyft_z['avg_driver_pay']:.2f}"), unsafe_allow_html=True)

        st.markdown("<div style='margin-top: 8px;'></div>", unsafe_allow_html=True)

        c1, c2 = st.columns(2)
        with c1:
            st.markdown(metric_card("Pay Per Mile", f"${lyft_z['avg_pay_per_mile']:.2f}"), unsafe_allow_html=True)
        with c2:
            st.markdown(metric_card("Pay Per Minute", f"${lyft_z['avg_pay_per_minute']:.2f}"), unsafe_allow_html=True)

    st.markdown("---")

    # Airport trips
    st.markdown('<div class="section-header">Airport Trips: YoY Comparison</div>', unsafe_allow_html=True)
    st.caption("Uber dominates airport volume at 15.1M trips but slipped 0.4% year over year. Lyft grew airport trips 8.6% while charging $8.83 less per fare on average, suggesting Lyft is winning budget-conscious airport riders while Uber holds the premium end.")

    uber_air = load("uber_airport.csv").iloc[0]
    lyft_air = load("lyft_airport.csv").iloc[0]

    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.markdown(metric_card("Uber Airport Trips", fmt_trips(uber_air["airport_trips_2025"]), uber_air["trip_growth_pct"]), unsafe_allow_html=True)
    with c2:
        st.markdown(metric_card("Uber Avg Airport Fare", f"${uber_air['avg_fare_2025']:.2f}", uber_air["avg_fare_growth_pct"]), unsafe_allow_html=True)
    with c3:
        st.markdown(metric_card("Lyft Airport Trips", fmt_trips(lyft_air["airport_trips_2025"]), lyft_air["trip_growth_pct"]), unsafe_allow_html=True)
    with c4:
        st.markdown(metric_card("Lyft Avg Airport Fare", f"${lyft_air['avg_fare_2025']:.2f}", lyft_air["avg_fare_growth_pct"]), unsafe_allow_html=True)


# ══════════════════════════════════════════════════════════════════════════════
# METHODOLOGY
# ══════════════════════════════════════════════════════════════════════════════
elif page == "Methodology":
    st.title("Methodology & Notes")
    st.markdown("---")

    st.markdown("""
    <div class="finding-box">
    <b>Data Source</b><br>
    NYC Taxi and Limousine Commission (TLC) High Volume For-Hire Vehicle trip records.
    Full year 2024 and 2025 data covering over 400 million records across both years,
    processed in Google BigQuery.
    </div>

    <div class="finding-box">
    <b>Company Identification</b><br>
    Companies are identified via the <code>hvfhs_license_num</code> field in the TLC dataset.
    HV0003 is Uber and HV0005 is Lyft. Other operators including Juno (HV0002) and Via (HV0004)
    are excluded from all analysis to ensure clean Uber vs Lyft comparisons.
    </div>

    <div class="finding-box">
    <b>Congestion Zone Definition</b><br>
    For 2025, trips are identified as congestion zone trips using <code>cbd_congestion_fee > 0</code>,
    which isolates trips where the MTA Congestion Relief Zone fee was applied below 60th Street in Manhattan.
    This field does not exist in 2024 data since the fee was not yet in effect.
    Manhattan borough is used as a broader proxy for zone-adjacent activity in 2024 comparisons.
    </div>

    <div class="finding-box">
    <b>Pickups vs Dropoffs</b><br>
    Manhattan queries are intentionally split into separate pickup and dropoff analyses.
    Pickups measure rider demand entering the zone. Dropoffs measure driver supply serving the zone.
    Combining them would mask the behavioral differences between how riders and drivers each
    responded to the fee.
    </div>

    <div class="finding-box">
    <b>Revenue Definitions</b><br>
    <b>Gross bookings</b> = base_passenger_fare, which excludes tolls, taxes, and fees.<br>
    <b>Net revenue</b> = base_passenger_fare minus driver_pay, representing the platform take.<br>
    <b>Driver earnings</b> = driver_pay plus tips.<br>
    All figures are in USD.
    </div>

    <div class="finding-box">
    <b>Year-over-Year Comparisons</b><br>
    All comparisons use full calendar year 2024 vs full calendar year 2025.
    Both datasets were cleaned and validated through the Part 1 and Part 2 pipeline,
    preserving 99.87% or more of original records.
    </div>

    <div class="finding-box">
    <b>Limitations</b><br>
    The 2024 congestion zone cannot be isolated with the same precision as 2025 due to the
    absence of the cbd_congestion_fee field in 2024 data. Year-over-year comparisons assume
    consistent data collection methodology between years. Driver behavior inferences are derived
    from aggregate trip patterns and cannot account for individual driver decision-making.
    Lyft's near-zero shared ride participation also limits the shared ride comparison.
    </div>
    """, unsafe_allow_html=True)

    st.markdown("---")
    st.markdown("**Part 3 of 3**: NYC Congestion Pricing Impact Analysis, Uber vs Lyft")
    st.markdown(
    "View the full series on GitHub: "
    "[Part 1: Quasi-Experimental Analysis](https://github.com/amontaywelch/NYC_Congestion_Quasi_Analysis) "
    "| [Part 2: Full Year YoY Analysis](https://github.com/amontaywelch/NYC-Rideshare-Analysis-Part-2) "
    "| [Part 3: Uber vs Lyft Competitive Breakdown](https://nyc-rideshare-analysis-part-3-fjsstencltzb5myc4py9z5.streamlit.app/). "
    "| Built with BigQuery, Python, and Streamlit.",
    unsafe_allow_html=True
)