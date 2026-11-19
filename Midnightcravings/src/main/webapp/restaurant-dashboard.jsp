<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null ||
        !"restaurant".equalsIgnoreCase(
            (String) session.getAttribute("role"))) {

        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    String restaurantName =
        (String) request.getAttribute("restaurantName");

    if (restaurantName == null) {
        response.sendError(
            403,
            "Open this page through the dashboard."
        );
        return;
    }

    String contextPath = request.getContextPath();

    // Escape restaurant name before displaying it.
    String safeRestaurantName = restaurantName
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");

    // Counts will be populated by the dashboard servlet.
    Object newCount = request.getAttribute("newOrdersCount");
    Object preparingCount = request.getAttribute("preparingOrdersCount");
    Object readyCount = request.getAttribute("readyOrdersCount");
    Object todayCount = request.getAttribute("todayOrdersCount");

    String newOrdersCount =
        newCount == null ? "—" : String.valueOf(newCount);

    String preparingOrdersCount =
        preparingCount == null ? "—" : String.valueOf(preparingCount);

    String readyOrdersCount =
        readyCount == null ? "—" : String.valueOf(readyCount);

    String todayOrdersCount =
        todayCount == null ? "—" : String.valueOf(todayCount);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Restaurant Studio | Midnight Cravings</title>

    <style>
        * {
            box-sizing: border-box;
        }

        :root {
            --cream: #FFFDF7;
            --yellow: #FFC025;
            --yellow-hover: #F2B313;
            --yellow-light: #FFF3C4;
            --ink: #29251C;
            --muted: #756D60;
            --border: #F0E4C3;
            --white: #FFFFFF;
            --green: #237A4B;
            --red: #B83A32;
        }

        body {
            margin: 0;
            padding: 30px;
            background: var(--cream);
            color: var(--ink);
            font-family: "Plus Jakarta Sans", Arial, sans-serif;
        }

        button,
        a {
            font-family: inherit;
        }

        .container {
            max-width: 1150px;
            margin: 0 auto;
        }

        /* Header */

        .header {
            background: var(--yellow);
            padding: 28px 30px;
            border-radius: 22px;
            box-shadow: 0 8px 24px rgba(126, 94, 0, 0.08);
        }

        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 22px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .brand-icon {
            width: 58px;
            height: 58px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            background: rgba(255, 255, 255, 0.65);
            border-radius: 17px;
            font-size: 29px;
        }

        .brand h1 {
            margin: 0 0 7px;
            font-size: 29px;
            letter-spacing: -0.8px;
        }

        .brand p {
            margin: 0;
            font-size: 14px;
            line-height: 1.6;
        }

        .active-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            margin-top: 12px;
            padding: 7px 12px;
            border-radius: 20px;
            background: #E2F5E8;
            color: #236B3D;
            font-size: 12px;
            font-weight: 700;
        }

        .active-dot {
            width: 7px;
            height: 7px;
            background: #299650;
            border-radius: 50%;
        }

        .logout-form {
            margin: 0;
        }

        .logout-btn {
            padding: 11px 19px;
            background: var(--white);
            color: var(--ink);
            border: 1px solid rgba(41, 37, 28, 0.12);
            border-radius: 11px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .logout-btn:hover {
            background: #FFF8E5;
        }

        /* Intro */

        .welcome-section {
            margin: 30px 0 23px;
        }

        .welcome-section h2 {
            margin: 0 0 9px;
            font-size: 25px;
            letter-spacing: -0.5px;
        }

        .welcome-section p {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.7;
        }

        /* Statistics */

        .section-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin: 27px 0 16px;
        }

        .section-heading h2 {
            margin: 0;
            font-size: 20px;
        }

        .section-heading p {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;
        }

        .stat-card {
            min-width: 0;
            padding: 22px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 18px;
            box-shadow: 0 4px 14px rgba(41, 37, 28, 0.025);
            transition: transform 0.2s ease,
                        box-shadow 0.2s ease,
                        border-color 0.2s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            border-color: var(--yellow);
            box-shadow: 0 8px 22px rgba(41, 37, 28, 0.06);
        }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 19px;
        }

        .stat-icon {
            width: 43px;
            height: 43px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--yellow-light);
            border-radius: 13px;
            font-size: 21px;
        }

        .stat-number {
            margin: 0 0 6px;
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -1px;
        }

        .stat-label {
            margin: 0;
            font-size: 13px;
            font-weight: 700;
        }

        .stat-description {
            margin: 8px 0 0;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.6;
        }

        /* Order management panel */

        .panel {
            margin-top: 27px;
            padding: 27px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 20px;
        }

        .panel-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            justify-content: space-between;
        }

        .panel-title-group {
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }

        .panel-icon {
            width: 48px;
            height: 48px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            background: var(--yellow-light);
            border-radius: 14px;
            font-size: 23px;
        }

        .panel h2 {
            margin: 1px 0 8px;
            font-size: 21px;
        }

        .panel-description {
            margin: 0;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.7;
        }

        .orders-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            flex-shrink: 0;
            margin-top: 20px;
            padding: 14px 20px;
            background: var(--yellow);
            color: var(--ink);
            border: 1px solid var(--yellow);
            border-radius: 11px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 800;
            transition: background 0.2s ease,
                        transform 0.2s ease;
        }

        .orders-link:hover {
            background: var(--yellow-hover);
            transform: translateY(-1px);
        }

        .orders-link:focus-visible,
        .logout-btn:focus-visible,
        .confirm-logout-btn:focus-visible,
        .cancel-btn:focus-visible {
            outline: 2px solid var(--ink);
            outline-offset: 3px;
        }

        /* Workflow steps */

        .workflow {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 13px;
            margin-top: 25px;
        }

        .workflow-step {
            padding: 17px;
            background: #FFFCF3;
            border: 1px solid #F2E8CE;
            border-radius: 14px;
        }

        .workflow-number {
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
            background: var(--yellow);
            border-radius: 9px;
            font-size: 13px;
            font-weight: 800;
        }

        .workflow-step h3 {
            margin: 0 0 7px;
            font-size: 14px;
        }

        .workflow-step p {
            margin: 0;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.7;
        }

        .info {
            margin-top: 23px;
            padding: 16px 18px;
            background: #FFF8E5;
            border: 1px solid #F5E7BF;
            border-radius: 12px;
            color: #625333;
            font-size: 13px;
            line-height: 1.7;
        }

        .info strong {
            color: var(--ink);
        }

        /* Logout confirmation modal */

        .logout-modal {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 9999;
            padding: 20px;
            background: rgba(41, 37, 28, 0.58);
            align-items: center;
            justify-content: center;
        }

        .logout-modal.show {
            display: flex;
        }

        .logout-modal-content {
            width: 100%;
            max-width: 400px;
            padding: 32px 26px;
            background: var(--cream);
            border: 1px solid var(--border);
            border-radius: 20px;
            text-align: center;
            box-shadow: 0 20px 60px rgba(41, 37, 28, 0.2);
            animation: popupAppear 0.2s ease-out;
        }

        .logout-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--yellow-light);
            color: var(--ink);
            border-radius: 50%;
            font-size: 27px;
            font-weight: 800;
        }

        .logout-modal-content h2 {
            margin: 0 0 12px;
            font-size: 23px;
        }

        .logout-modal-content p {
            margin: 0 0 26px;
            color: var(--muted);
            font-size: 14px;
            line-height: 1.7;
        }

        .logout-modal-actions {
            display: flex;
            gap: 12px;
        }

        .cancel-btn,
        .confirm-logout-btn {
            flex: 1;
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease;
        }

        .cancel-btn {
            background: transparent;
            color: var(--ink);
            border: 1px solid #E8DDBF;
        }

        .cancel-btn:hover {
            background: var(--yellow-light);
        }

        .confirm-logout-btn {
            background: var(--yellow);
            color: var(--ink);
            border: 1px solid var(--yellow);
        }

        .confirm-logout-btn:hover {
            background: var(--yellow-hover);
        }

        @keyframes popupAppear {
            from {
                opacity: 0;
                transform: translateY(8px) scale(0.97);
            }

            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* Responsive layout */

        @media (max-width: 900px) {
            .stats-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .header-top {
                align-items: flex-start;
            }
        }

        @media (max-width: 600px) {
            body {
                padding: 15px;
            }

            .header {
                padding: 21px;
                border-radius: 17px;
            }

            .header-top {
                flex-direction: column;
                align-items: stretch;
            }

            .brand {
                align-items: flex-start;
            }

            .brand-icon {
                width: 48px;
                height: 48px;
                font-size: 24px;
            }

            .brand h1 {
                font-size: 23px;
            }

            .logout-btn {
                width: 100%;
            }

            .welcome-section {
                margin-top: 25px;
            }

            .welcome-section h2 {
                font-size: 22px;
            }

            .stats-grid {
                gap: 11px;
            }

            .stat-card {
                padding: 16px;
                border-radius: 15px;
            }

            .stat-number {
                font-size: 26px;
            }

            .stat-label {
                font-size: 12px;
            }

            .panel {
                padding: 19px;
                border-radius: 16px;
            }

            .panel-header {
                flex-direction: column;
            }

            .orders-link {
                width: 100%;
            }

            .workflow {
                grid-template-columns: 1fr;
            }

            .section-heading h2 {
                font-size: 18px;
            }

            .logout-modal-content {
                padding: 26px 18px;
            }

            .logout-modal-actions {
                flex-direction: column;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                animation-duration: 0.01ms !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>

<body>

<div class="container">

    <!-- Dashboard header -->
    <header class="header">
        <div class="header-top">

            <div class="brand">
                <div class="brand-icon" aria-hidden="true">🍕</div>

                <div>
                    <h1>Restaurant Studio</h1>

                    <p>
                        Welcome,
                        <strong><%= safeRestaurantName %></strong>!
                    </p>

                    <span class="active-badge">
                        <span class="active-dot"></span>
                        Restaurant Dashboard
                    </span>
                </div>
            </div>

            <form class="logout-form"
                  id="logoutForm"
                  action="<%= contextPath %>/logout"
                  method="post">

                <button type="button"
                        class="logout-btn"
                        onclick="openLogoutModal()">
                    Logout ↗
                </button>
            </form>

        </div>
    </header>

    <!-- Welcome section -->
    <section class="welcome-section">
        <h2>Today's overview</h2>

        <p>
            Keep track of incoming orders, prepare meals on time,
            and help customers stay updated on their orders.
        </p>
    </section>

    <!-- Statistics -->
    <div class="section-heading">
        <h2>Order summary</h2>
        <p>Restaurant activity</p>
    </div>

    <section class="stats-grid" aria-label="Order summary">

        <article class="stat-card">
            <div class="stat-top">
                <div class="stat-icon" aria-hidden="true">🔔</div>
            </div>

            <p class="stat-number"><%= newOrdersCount %></p>
            <p class="stat-label">New orders</p>

            <p class="stat-description">
                Orders waiting for your response.
            </p>
        </article>

        <article class="stat-card">
            <div class="stat-top">
                <div class="stat-icon" aria-hidden="true">🍳</div>
            </div>

            <p class="stat-number"><%= preparingOrdersCount %></p>
            <p class="stat-label">Preparing</p>

            <p class="stat-description">
                Orders being prepared in your kitchen.
            </p>
        </article>

        <article class="stat-card">
            <div class="stat-top">
                <div class="stat-icon" aria-hidden="true">📦</div>
            </div>

            <p class="stat-number"><%= readyOrdersCount %></p>
            <p class="stat-label">Ready for pickup</p>

            <p class="stat-description">
                Orders ready for the delivery agent.
            </p>
        </article>

        <article class="stat-card">
            <div class="stat-top">
                <div class="stat-icon" aria-hidden="true">🛍️</div>
            </div>

            <p class="stat-number"><%= todayOrdersCount %></p>
            <p class="stat-label">Today's orders</p>

            <p class="stat-description">
                Total orders received today.
            </p>
        </article>

    </section>

    <!-- Order management -->
    <section class="panel">

        <div class="panel-header">

            <div class="panel-title-group">
                <div class="panel-icon" aria-hidden="true">📋</div>

                <div>
                    <h2>Order management</h2>

                    <p class="panel-description">
                        Review customer orders, check dishes and quantities,
                        view delivery addresses, and manage preparation status.
                    </p>
                </div>
            </div>

        </div>

        <a class="orders-link"
           href="<%= contextPath %>/restaurant-orders">
            View and manage orders
            <span aria-hidden="true">→</span>
        </a>

        <!-- Workflow guide -->
        <div class="workflow">

            <article class="workflow-step">
                <div class="workflow-number">01</div>

                <h3>Review incoming orders</h3>

                <p>
                    Check the items, quantities, payment method,
                    customer details, and delivery address.
                </p>
            </article>

            <article class="workflow-step">
                <div class="workflow-number">02</div>

                <h3>Accept and prepare</h3>

                <p>
                    Accept an order and update its status when
                    your kitchen starts preparing it.
                </p>
            </article>

            <article class="workflow-step">
                <div class="workflow-number">03</div>

                <h3>Ready for pickup</h3>

                <p>
                    Mark prepared orders ready so the delivery
                    workflow can continue.
                </p>
            </article>

        </div>

        <div class="info">
            <strong>Restaurant tip:</strong>
            Keep order statuses up to date so customers and delivery
            agents can follow the order's progress.
        </div>

    </section>

</div>

<!-- Logout confirmation modal -->
<div id="logoutModal"
     class="logout-modal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="logoutModalTitle"
     aria-describedby="logoutModalMessage">

    <div class="logout-modal-content">

        <div class="logout-icon" aria-hidden="true">↗</div>

        <h2 id="logoutModalTitle">Leaving so soon?</h2>

        <p id="logoutModalMessage">
            Are you sure you want to logout from Midnight Cravings?
        </p>

        <div class="logout-modal-actions">

            <button type="button"
                    class="cancel-btn"
                    onclick="closeLogoutModal()">
                Cancel
            </button>

            <button type="button"
                    class="confirm-logout-btn"
                    id="confirmLogoutButton"
                    onclick="confirmLogout()">
                Yes, Logout
            </button>

        </div>
    </div>
</div>

<script>
    const logoutModal = document.getElementById("logoutModal");
    const confirmLogoutButton =
        document.getElementById("confirmLogoutButton");
    const logoutButton =
        document.querySelector(".logout-btn");

    function openLogoutModal() {
        logoutModal.classList.add("show");
        confirmLogoutButton.focus();
    }

    function closeLogoutModal() {
        logoutModal.classList.remove("show");

        if (logoutButton) {
            logoutButton.focus();
        }
    }

    function confirmLogout() {
        document.getElementById("logoutForm").submit();
    }

    // Close the modal when clicking outside it.
    logoutModal.addEventListener("click", function(event) {
        if (event.target === logoutModal) {
            closeLogoutModal();
        }
    });

    // Close the modal using Escape.
    document.addEventListener("keydown", function(event) {
        if (event.key === "Escape" &&
            logoutModal.classList.contains("show")) {
            closeLogoutModal();
        }
    });
</script>

</body>
</html>