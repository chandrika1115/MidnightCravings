
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.List,java.util.Locale,com.tap.controller.DeliveryAgentDashboardServlet.Delivery" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (session == null
            || session.getAttribute("userId") == null
            || !"deliveryagent".equalsIgnoreCase(
                    String.valueOf(session.getAttribute("role")))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();

    String username = String.valueOf(
        session.getAttribute("username") == null
            ? "Delivery Agent"
            : session.getAttribute("username")
    );

    List<Delivery> deliveries =
        (List<Delivery>) request.getAttribute("deliveries");

    String flashMessage =
        (String) session.getAttribute("flashMessage");

    if (flashMessage != null) {
        session.removeAttribute("flashMessage");
    }

    int deliveryCount = deliveries == null ? 0 : deliveries.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Delivery Agent Dashboard | Midnight Cravings</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
      rel="stylesheet">

<style>
:root {
    --cream: #FFFDF7;
    --yellow: #FFC025;
    --text: #29251C;
    --muted: #777267;
    --border: #EEE8D9;
    --white: #FFFFFF;
    --green: #218653;
    --red: #C43D32;
    --shadow: 0 8px 28px rgba(41,37,28,.07);
}

* { box-sizing: border-box; }

body {
    margin: 0;
    background: var(--cream);
    color: var(--text);
    font-family: 'Plus Jakarta Sans', sans-serif;
}

button, input { font: inherit; }
button { cursor: pointer; }

.navbar {
    position: sticky;
    top: 0;
    z-index: 10;
    background: rgba(255,253,247,.96);
    border-bottom: 1px solid var(--border);
    backdrop-filter: blur(10px);
}

.nav-inner {
    max-width: 1200px;
    min-height: 76px;
    padding: 12px 24px;
    margin: auto;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 18px;
}

.brand {
    display: flex;
    align-items: center;
    color: var(--text);
    text-decoration: none;
    font-size: 20px;
    font-weight: 800;
    letter-spacing: -.5px;
}

.brand small {
    display: block;
    margin-top: 3px;
    color: var(--muted);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 1.6px;
    text-transform: uppercase;
}

.nav-right {
    display: flex;
    align-items: center;
    gap: 15px;
}

.nav-right form { margin: 0; }

.agent-name {
    font-size: 13px;
    font-weight: 700;
}

.logout-btn {
    border: 1px solid var(--border);
    background: var(--white);
    color: var(--text);
    border-radius: 10px;
    padding: 10px 15px;
    font-weight: 700;
}

.logout-btn:hover { background: #FFF3D0; }

.page {
    max-width: 1200px;
    margin: auto;
    padding: 30px 24px 55px;
}

.welcome {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    padding: 30px;
    border-radius: 22px;
    background: linear-gradient(120deg,#FFF0BF,#FFF9E9);
    border: 1px solid #F4E2AC;
    margin-bottom: 24px;
}

.welcome h1 {
    margin: 0 0 9px;
    font-size: clamp(24px,4vw,34px);
    letter-spacing: -1.1px;
}

.welcome p {
    margin: 0;
    color: #69604D;
    font-size: 14px;
    line-height: 1.7;
}

.welcome-icon {
    width: 76px;
    height: 76px;
    flex-shrink: 0;
    display: grid;
    place-items: center;
    border-radius: 22px;
    background: var(--yellow);
    font-size: 36px;
}

.flash-message {
    margin-bottom: 20px;
    padding: 14px 17px;
    border-radius: 12px;
    background: #E9F8EE;
    color: #216B40;
    border: 1px solid #C9EBD4;
    font-size: 13px;
    font-weight: 700;
}

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin: 28px 0 17px;
}

.section-heading h2 {
    font-size: 21px;
    margin: 0;
    letter-spacing: -.5px;
}

.count-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 32px;
    height: 30px;
    padding: 0 10px;
    border-radius: 20px;
    background: #FFF0BF;
    color: #785800;
    font-size: 12px;
    font-weight: 800;
}

.gps-panel {
    padding: 24px;
    margin-bottom: 30px;
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: 20px;
    box-shadow: var(--shadow);
}

.gps-header {
    display: flex;
    align-items: flex-start;
    gap: 14px;
    margin-bottom: 15px;
}

.gps-icon {
    width: 47px;
    height: 47px;
    display: grid;
    place-items: center;
    flex-shrink: 0;
    border-radius: 14px;
    background: #FFF0BF;
    font-size: 24px;
}

.gps-header h2 {
    margin: 2px 0 7px;
    font-size: 19px;
}

.gps-header p {
    margin: 0;
    font-size: 13px;
    line-height: 1.7;
    color: var(--muted);
}

.gps-status {
    margin: 17px 0;
    padding: 13px 15px;
    border-radius: 11px;
    background: #F7F5EF;
    color: #645D4D;
    font-size: 13px;
    line-height: 1.7;
    overflow-wrap: anywhere;
}

.gps-status.success {
    background: #E9F8EE;
    color: #216B40;
}

.gps-status.error {
    background: #FFF0EE;
    color: #A32D24;
}

.gps-status.warning {
    background: #FFF6D9;
    color: #785800;
}

.gps-actions, .card-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.btn {
    display: inline-flex;
    justify-content: center;
    align-items: center;
    border: 0;
    border-radius: 10px;
    padding: 11px 17px;
    font-size: 12px;
    font-weight: 800;
    text-decoration: none;
    transition: transform .15s, opacity .15s;
}

.btn:hover { transform: translateY(-1px); }

.btn:disabled {
    opacity: .5;
    cursor: not-allowed;
    transform: none;
}

.btn-yellow { background: var(--yellow); color: var(--text); }
.btn-light { background: #F5F2E9; color: var(--text); }
.btn-green { background: #E3F5E9; color: #216B40; }
.btn-red { background: #FCE9E6; color: #A32D24; }

.deliveries-grid {
    display: grid;
    grid-template-columns: repeat(2,minmax(0,1fr));
    gap: 20px;
}

.delivery-card {
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: 19px;
    padding: 23px;
    box-shadow: var(--shadow);
    min-width: 0;
}

.card-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 12px;
    padding-bottom: 18px;
    border-bottom: 1px solid #F0ECE3;
}

.order-label {
    color: var(--muted);
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.order-number {
    margin-top: 6px;
    font-size: 22px;
    font-weight: 800;
}

.status-pill {
    display: inline-block;
    padding: 7px 10px;
    border-radius: 30px;
    background: #FFF0BF;
    color: #785800;
    font-size: 10px;
    font-weight: 800;
    text-align: center;
}

.status-accepted,
.status-picked-up,
.status-out-for-delivery {
    background: #E7F0FF;
    color: #28569D;
}

.status-delivered {
    background: #E3F5E9;
    color: #216B40;
}

.status-rejected {
    background: #FCE9E6;
    color: #A32D24;
}

.info-block {
    padding: 16px 0;
    border-bottom: 1px solid #F0ECE3;
}

.info-label {
    display: block;
    margin-bottom: 7px;
    color: var(--muted);
    font-size: 10px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: .9px;
}

.info-value {
    font-size: 13px;
    line-height: 1.7;
    overflow-wrap: anywhere;
}

.info-value strong { font-weight: 800; }
.amount { font-size: 18px; font-weight: 800; }

.card-actions { padding-top: 18px; }
.card-actions form { margin: 0; }

.no-deliveries {
    grid-column: 1 / -1;
    padding: 45px 20px;
    text-align: center;
    background: var(--white);
    border: 1px dashed #DED5C2;
    border-radius: 19px;
}

.empty-icon {
    font-size: 38px;
    margin-bottom: 13px;
}

.no-deliveries h3 {
    margin: 0 0 8px;
    font-size: 18px;
}

.no-deliveries p {
    margin: 0;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.7;
}

.footer-note {
    margin-top: 30px;
    color: var(--muted);
    text-align: center;
    font-size: 11px;
    line-height: 1.7;
}

@media (max-width:760px) {
    .deliveries-grid { grid-template-columns: 1fr; }
    .page { padding: 22px 15px 40px; }
    .nav-inner { padding: 12px 15px; }
    .brand { font-size: 16px; }
    .agent-name { display: none; }
    .welcome { padding: 23px; }

    .welcome-icon {
        width: 55px;
        height: 55px;
        border-radius: 16px;
        font-size: 26px;
    }

    .gps-panel { padding: 19px; }
}
</style>
</head>

<body>

<header class="navbar">
    <div class="nav-inner">
        <a class="brand"
           href="<%= contextPath %>/delivery-agent-dashboard">
            <span>
                Midnight Cravings
                <small>Delivery Partner</small>
            </span>
        </a>

        <div class="nav-right">
            <span class="agent-name">
                Hi, <%= escapeHtml(username) %>
            </span>

            <form id="logoutForm" method="post"
                  action="<%= contextPath %>/logout">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>
    </div>
</header>

<main class="page">

    <section class="welcome">
        <div>
            <h1>Welcome back, <%= escapeHtml(username) %>!</h1>
            <p>
                Manage your deliveries, update order statuses, and share
                your live location with customers while delivering orders.
            </p>
        </div>
        <div class="welcome-icon">🛵</div>
    </section>

    <% if (flashMessage != null && !flashMessage.trim().isEmpty()) { %>
        <div class="flash-message"><%= escapeHtml(flashMessage) %></div>
    <% } %>

    <section class="gps-panel">
        <div class="gps-header">
            <div class="gps-icon">📍</div>
            <div>
                <h2>Live GPS Tracking</h2>
                <p>
                    Start sharing after accepting a delivery. If you log out
                    while sharing, you can resume after logging in again.
                    Your browser may ask for location permission.
                </p>
            </div>
        </div>

        <div id="gpsStatus" class="gps-status"
             role="status" aria-live="polite">
            Checking GPS sharing state...
        </div>

        <div class="gps-actions">
            <button type="button" id="startGpsBtn"
                    class="btn btn-yellow" disabled>
                Start GPS Sharing
            </button>

            <button type="button" id="stopGpsBtn"
                    class="btn btn-light" disabled>
                Stop GPS Sharing
            </button>
        </div>
    </section>

    <div class="section-heading">
        <h2>Your Deliveries</h2>
        <span class="count-badge"><%= deliveryCount %></span>
    </div>

    <section class="deliveries-grid">
        <% if (deliveries == null || deliveries.isEmpty()) { %>

            <div class="no-deliveries">
                <div class="empty-icon">📦</div>
                <h3>No deliveries assigned</h3>
                <p>
                    You currently have no active delivery assignments.
                    New assignments will appear here when available.
                </p>
            </div>

        <% } else { %>

            <% for (Delivery delivery : deliveries) {
                String deliveryStatus = delivery.getDeliveryStatus();

                if (deliveryStatus == null) {
                    deliveryStatus = "Assigned";
                }

                String statusClass =
                    deliveryStatus.toLowerCase(Locale.ROOT)
                                  .replace(" ", "-");
            %>

                <article class="delivery-card">
                    <div class="card-top">
                        <div>
                            <div class="order-label">Order number</div>
                            <div class="order-number">
                                #<%= delivery.getOrderId() %>
                            </div>
                        </div>

                        <span class="status-pill status-<%= escapeHtml(statusClass) %>">
                            <%= escapeHtml(deliveryStatus) %>
                        </span>
                    </div>

                    <div class="info-block">
                        <span class="info-label">Restaurant pickup</span>
                        <div class="info-value">
                            <strong><%= escapeHtml(delivery.getRestaurantName()) %></strong>
                            <br>
                            <%= escapeHtml(delivery.getRestaurantAddress()) %>
                        </div>
                    </div>

                    <div class="info-block">
                        <span class="info-label">Customer delivery address</span>
                        <div class="info-value">
                            <%= escapeHtml(delivery.getDeliveryAddress()) %>
                        </div>
                    </div>

                    <div class="info-block">
                        <span class="info-label">Order details</span>
                        <div class="info-value">
                            <strong>Order status:</strong>
                            <%= escapeHtml(delivery.getOrderStatus()) %>
                            <br>

                            <strong>Payment:</strong>
                            <%= escapeHtml(delivery.getPaymentMethod()) %>
                            <br>

                            <strong>Assignment date:</strong>
                            <%= delivery.getAssignedAt() == null
                                ? "Not available"
                                : escapeHtml(String.valueOf(delivery.getAssignedAt())) %>
                        </div>
                    </div>

                    <div class="info-block">
                        <span class="info-label">Order amount</span>
                        <div class="amount">
                            ₹<%= delivery.getTotalAmount() %>
                        </div>
                    </div>

                    <div class="card-actions">
                        <% if ("Assigned".equalsIgnoreCase(deliveryStatus)) { %>

                            <form method="post"
                                  action="<%= contextPath %>/delivery-action">
                                <input type="hidden" name="assignmentId"
                                       value="<%= delivery.getAssignmentId() %>">
                                <input type="hidden" name="orderId"
                                       value="<%= delivery.getOrderId() %>">
                                <input type="hidden" name="action" value="accept">
                                <button type="submit" class="btn btn-green">
                                    Accept Delivery
                                </button>
                            </form>

                            <form method="post"
                                  action="<%= contextPath %>/delivery-action">
                                <input type="hidden" name="assignmentId"
                                       value="<%= delivery.getAssignmentId() %>">
                                <input type="hidden" name="orderId"
                                       value="<%= delivery.getOrderId() %>">
                                <input type="hidden" name="action" value="reject">
                                <button type="submit" class="btn btn-red">
                                    Reject
                                </button>
                            </form>

                        <% } else if ("Accepted".equalsIgnoreCase(deliveryStatus)) { %>

                            <form method="post"
                                  action="<%= contextPath %>/delivery-action">
                                <input type="hidden" name="assignmentId"
                                       value="<%= delivery.getAssignmentId() %>">
                                <input type="hidden" name="orderId"
                                       value="<%= delivery.getOrderId() %>">
                                <input type="hidden" name="action" value="pickup">
                                <button type="submit" class="btn btn-yellow">
                                    Picked Up
                                </button>
                            </form>

                        <% } else if ("Picked Up".equalsIgnoreCase(deliveryStatus)) { %>

                            <form method="post"
                                  action="<%= contextPath %>/delivery-action">
                                <input type="hidden" name="assignmentId"
                                       value="<%= delivery.getAssignmentId() %>">
                                <input type="hidden" name="orderId"
                                       value="<%= delivery.getOrderId() %>">
                                <input type="hidden" name="action"
                                       value="out-for-delivery">
                                <button type="submit" class="btn btn-yellow">
                                    Out for Delivery
                                </button>
                            </form>

                        <% } else if ("Out for Delivery".equalsIgnoreCase(deliveryStatus)) { %>

                            <form method="post"
                                  action="<%= contextPath %>/delivery-action">
                                <input type="hidden" name="assignmentId"
                                       value="<%= delivery.getAssignmentId() %>">
                                <input type="hidden" name="orderId"
                                       value="<%= delivery.getOrderId() %>">
                                <input type="hidden" name="action" value="delivered">
                                <button type="submit" class="btn btn-green">
                                    Mark Delivered
                                </button>
                            </form>

                        <% } else { %>

                            <span class="btn btn-light">
                                <%= escapeHtml(deliveryStatus) %>
                            </span>

                        <% } %>
                    </div>
                </article>

            <% } %>
        <% } %>
    </section>

    <p class="footer-note">
        Midnight Cravings · Delivery Partner Dashboard<br>
        Live GPS requires browser location permission and an eligible delivery.
    </p>

</main>

<script>
(function () {
    "use strict";

    const contextPath = "<%= contextPath %>";

    const gpsStatus = document.getElementById("gpsStatus");
    const startGpsBtn = document.getElementById("startGpsBtn");
    const stopGpsBtn = document.getElementById("stopGpsBtn");
    const logoutForm = document.getElementById("logoutForm");

    const activeOrderIds = [
        <%
            boolean firstGpsOrder = true;

            if (deliveries != null) {
                for (Delivery gpsDelivery : deliveries) {
                    String gpsStatusValue = gpsDelivery.getDeliveryStatus();

                    if ("Accepted".equalsIgnoreCase(gpsStatusValue)
                            || "Picked Up".equalsIgnoreCase(gpsStatusValue)
                            || "Out for Delivery".equalsIgnoreCase(gpsStatusValue)) {

                        if (!firstGpsOrder) {
                            out.print(",");
                        }

                        out.print(gpsDelivery.getOrderId());
                        firstGpsOrder = false;
                    }
                }
            }
        %>
    ];

    let watchId = null;
    let isSharing = false;
    let savedSharingPreference = false;
    let lastSentAt = 0;
    let isSending = false;
    let stateRequestInProgress = false;
    let latestPosition = null;
    let leavingDashboard = false;

    function showStatus(message, type) {
        gpsStatus.textContent = message;
        gpsStatus.className = "gps-status" + (type ? " " + type : "");
    }

    function updateButtons() {
        startGpsBtn.disabled =
            isSharing || stateRequestInProgress || activeOrderIds.length === 0;

        stopGpsBtn.disabled =
            (!isSharing && !savedSharingPreference) || stateRequestInProgress;

        if (isSharing) {
            startGpsBtn.textContent = "GPS Sharing Active";
        } else if (savedSharingPreference) {
            startGpsBtn.textContent = "Resume GPS Sharing";
        } else {
            startGpsBtn.textContent = "Start GPS Sharing";
        }
    }

    async function readGpsState() {
        const response = await fetch(
            contextPath + "/delivery-gps-state",
            {
                method: "GET",
                credentials: "same-origin",
                cache: "no-store",
                headers: { "Accept": "application/json" }
            }
        );

        const text = await response.text();
        let data;

        try {
            data = JSON.parse(text);
        } catch (error) {
            throw new Error("GPS state endpoint did not return JSON.");
        }

        if (!response.ok || data.success !== true) {
            throw new Error(data.message || "Could not read GPS state.");
        }

        return data;
    }

    async function saveGpsState(enabled) {
        const response = await fetch(
            contextPath + "/delivery-gps-state",
            {
                method: "POST",
                credentials: "same-origin",
                cache: "no-store",
                headers: {
                    "Content-Type":
                        "application/x-www-form-urlencoded; charset=UTF-8",
                    "Accept": "application/json"
                },
                body: new URLSearchParams({
                    isSharing: String(enabled)
                })
            }
        );

        const text = await response.text();
        let data;

        try {
            data = JSON.parse(text);
        } catch (error) {
            throw new Error("GPS state endpoint did not return JSON.");
        }

        if (!response.ok || data.success !== true) {
            throw new Error(data.message || "Could not save GPS state.");
        }

        savedSharingPreference = enabled;
        updateButtons();

        return data;
    }

    function stopLocalWatcher() {
        isSharing = false;
        latestPosition = null;

        if (watchId !== null && navigator.geolocation) {
            navigator.geolocation.clearWatch(watchId);
            watchId = null;
        }

        updateButtons();
    }

    async function sendLocation(position) {
        if (!isSharing || isSending || !position || leavingDashboard) {
            return;
        }

        if (activeOrderIds.length === 0) {
            showStatus("No eligible active deliveries are available.", "warning");
            return;
        }

        if (Date.now() - lastSentAt < 10000) {
            latestPosition = position;
            return;
        }

        isSending = true;
        latestPosition = null;

        try {
            for (const orderId of activeOrderIds) {
                if (!isSharing || leavingDashboard) break;

                const response = await fetch(
                    contextPath + "/update-delivery-location",
                    {
                        method: "POST",
                        credentials: "same-origin",
                        cache: "no-store",
                        headers: {
                            "Content-Type":
                                "application/x-www-form-urlencoded; charset=UTF-8",
                            "Accept": "application/json"
                        },
                        body: new URLSearchParams({
                            orderId: String(orderId),
                            latitude: String(position.coords.latitude),
                            longitude: String(position.coords.longitude)
                        })
                    }
                );

                const text = await response.text();
                let result;

                try {
                    result = JSON.parse(text);
                } catch (error) {
                    throw new Error(
                        "Unexpected response while updating order #" + orderId
                    );
                }

                if (!response.ok || result.success !== true) {
                    throw new Error(
                        result.message || "Location update failed."
                    );
                }
            }

            lastSentAt = Date.now();

            if (isSharing && !leavingDashboard) {
                showStatus(
                    "GPS sharing is active. Last update: " +
                    new Date().toLocaleTimeString(),
                    "success"
                );
            }
        } catch (error) {
            console.error("GPS update failed:", error);

            if (isSharing && !leavingDashboard) {
                showStatus(
                    "Could not save the latest location: " + error.message,
                    "error"
                );
            }
        } finally {
            isSending = false;

            if (isSharing && latestPosition && !leavingDashboard
                    && Date.now() - lastSentAt >= 10000) {
                const pending = latestPosition;
                latestPosition = null;
                sendLocation(pending);
            }
        }
    }

    function handleGpsError(error) {
        let message = "Unable to read your GPS location.";

        if (error && error.code === 1) {
            message = "Location permission was denied. Allow location access in your browser.";
        } else if (error && error.code === 2) {
            message = "Your location is unavailable. Check your device location settings.";
        } else if (error && error.code === 3) {
            message = "Getting your location timed out. Please try again.";
        }

        showStatus(message, "error");
        console.error("GPS error:", error);
    }

    async function startGps() {
        if (isSharing || stateRequestInProgress || leavingDashboard) return;

        if (activeOrderIds.length === 0) {
            showStatus(
                "Accept a delivery first. GPS sharing is available only for eligible active deliveries.",
                "warning"
            );
            return;
        }

        if (!navigator.geolocation) {
            showStatus("This browser does not support GPS location.", "error");
            return;
        }

        if (!window.isSecureContext) {
            showStatus(
                "GPS requires HTTPS or localhost. Use localhost while testing.",
                "error"
            );
            return;
        }

        stateRequestInProgress = true;
        updateButtons();
        showStatus("Starting GPS sharing...", "");

        try {
            const position = await new Promise((resolve, reject) => {
                navigator.geolocation.getCurrentPosition(
                    resolve,
                    reject,
                    {
                        enableHighAccuracy: true,
                        timeout: 20000,
                        maximumAge: 0
                    }
                );
            });

            await saveGpsState(true);

            isSharing = true;
            lastSentAt = 0;
            updateButtons();

            await sendLocation(position);

            if (!isSharing || leavingDashboard) return;

            watchId = navigator.geolocation.watchPosition(
                function (newPosition) {
                    if (!isSharing || leavingDashboard) return;

                    latestPosition = newPosition;

                    if (Date.now() - lastSentAt >= 10000 && !isSending) {
                        sendLocation(newPosition);
                    }
                },
                function (error) {
                    if (leavingDashboard) return;

                    handleGpsError(error);
                    stopLocalWatcher();

                    savedSharingPreference = false;

                    saveGpsState(false).catch(function (saveError) {
                        console.error("Could not reset GPS state:", saveError);
                    });
                },
                {
                    enableHighAccuracy: true,
                    maximumAge: 5000,
                    timeout: 20000
                }
            );

            showStatus("GPS sharing is active for your current deliveries.", "success");

        } catch (error) {
            console.error("Unable to start GPS:", error);
            stopLocalWatcher();

            try {
                await saveGpsState(false);
            } catch (saveError) {
                console.error("Could not reset GPS state:", saveError);
            }

            showStatus(
                "GPS could not start. Check browser location permission and try again.",
                "error"
            );
        } finally {
            stateRequestInProgress = false;
            updateButtons();
        }
    }

    async function stopGps() {
        if (stateRequestInProgress) return;

        stateRequestInProgress = true;
        stopLocalWatcher();
        savedSharingPreference = false;
        updateButtons();

        showStatus("Stopping GPS sharing...", "");

        try {
            await saveGpsState(false);

            showStatus("GPS sharing has been stopped.", "success");
        } catch (error) {
            console.error("Could not save stopped state:", error);

            showStatus(
                "GPS stopped in this browser, but the server could not save the stopped state.",
                "error"
            );
        } finally {
            stateRequestInProgress = false;
            updateButtons();
        }
    }

    /*
     * Picked Up:
     * Stop local tracking and save isSharing=false before submitting
     * the existing delivery action form.
     */
    document.querySelectorAll('form[action$="/delivery-action"]').forEach(function (form) {
        form.addEventListener("submit", async function (event) {
            const actionInput = form.querySelector('input[name="action"]');
            const action = actionInput ? actionInput.value : "";

            if (action !== "pickup") return;

            event.preventDefault();

            if (form.dataset.submitting === "true") return;
            form.dataset.submitting = "true";

            stateRequestInProgress = true;
            stopLocalWatcher();
            savedSharingPreference = false;
            updateButtons();

            showStatus("Stopping GPS sharing before confirming pickup...", "");

            try {
                await saveGpsState(false);
                showStatus("GPS sharing stopped. Updating delivery status...", "success");
            } catch (error) {
                console.error("Could not save GPS stopped state:", error);
                showStatus(
                    "Could not confirm the GPS stopped state. Continuing with pickup; the server should also reset GPS.",
                    "warning"
                );
            }

            form.submit();
        });
    });

    /*
     * Logout:
     * Stop the browser watcher, but preserve the saved preference.
     * After logging in again, Resume GPS Sharing can appear.
     */
    logoutForm.addEventListener("submit", function () {
        leavingDashboard = true;
        stopLocalWatcher();

        // Intentionally do NOT call saveGpsState(false) here.
        // The saved preference must remain available for Resume.
    });

    async function initializeGpsState() {
        stateRequestInProgress = true;
        isSharing = false;
        updateButtons();

        try {
            const data = await readGpsState();

            savedSharingPreference = data.isSharing === true;

            if (savedSharingPreference) {
                showStatus(
                    "GPS sharing was enabled previously. Click Resume GPS Sharing to restart live updates.",
                    "warning"
                );
            } else {
                showStatus(
                    "GPS sharing is stopped. Click Start GPS Sharing when ready.",
                    ""
                );
            }
        } catch (error) {
            console.error("Unable to read GPS state:", error);
            savedSharingPreference = false;

            showStatus(
                "Could not read saved GPS state. Check DeliveryGpsStateServlet.",
                "error"
            );
        } finally {
            stateRequestInProgress = false;
            updateButtons();
        }
    }

    startGpsBtn.addEventListener("click", startGps);
    stopGpsBtn.addEventListener("click", stopGps);

    window.addEventListener("pagehide", function () {
        // Stop local browser monitoring without clearing saved preference.
        stopLocalWatcher();
    });

    initializeGpsState();
})();
</script>

</body>
</html>
