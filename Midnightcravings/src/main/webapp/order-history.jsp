
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.tap.utility.DBConnection" %>
<%@ page import="jakarta.servlet.ServletException" %>

<%!
    public String escapeHtml(Object value) {
        if (value == null) return "";

        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    public String getImageUrl(Object value) {
        if (value == null) return "";

        String path = String.valueOf(value).trim().replace("\\", "/");

        // Remove leading slashes so the context path is not duplicated.
        while (path.startsWith("/")) {
            path = path.substring(1);
        }

        // Encode spaces and other unsafe characters in individual path segments.
        String[] segments = path.split("/", -1);
        StringBuilder encodedPath = new StringBuilder();

        for (int i = 0; i < segments.length; i++) {
            if (i > 0) encodedPath.append("/");

            try {
                encodedPath.append(
                    java.net.URLEncoder.encode(
                        segments[i], java.nio.charset.StandardCharsets.UTF_8.name()
                    ).replace("+", "%20")
                );
            } catch (java.io.UnsupportedEncodingException e) {
                encodedPath.append(segments[i]);
            }
        }

        return encodedPath.toString();
    }
%>

<%
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        session.setAttribute(
            "redirectAfterLogin",
            request.getContextPath() + "/order-history.jsp"
        );

        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    String contextPath = request.getContextPath();

    List<Map<String, Object>> orders = new ArrayList<>();

    String sql =
        "SELECT o.orderId, o.orderDate, o.totalAmount, " +
        "o.status, o.paymentMethod, r.name AS restaurantName " +
        "FROM orders o " +
        "LEFT JOIN restaurant r ON o.restaurantId = r.restaurantId " +
        "WHERE o.userId = ? " +
        "ORDER BY o.orderDate DESC";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> order = new HashMap<>();

                order.put("orderId", rs.getInt("orderId"));
                order.put("orderDate", rs.getTimestamp("orderDate"));
                order.put("totalAmount", rs.getBigDecimal("totalAmount"));
                order.put("status", rs.getString("status"));
                order.put("paymentMethod", rs.getString("paymentMethod"));
                order.put("restaurantName", rs.getString("restaurantName"));

                orders.add(order);
            }
        }
    } catch (SQLException e) {
        throw new ServletException("Unable to load order history.", e);
    }

    /*
     * Load item names, quantities, and menu image paths.
     */
    String itemSql =
        "SELECT m.itemName, oi.quantity, m.imagePath " +
        "FROM orderItem oi " +
        "JOIN menu m ON oi.menuId = m.menuId " +
        "WHERE oi.orderId = ? " +
        "ORDER BY oi.orderItemId";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(itemSql)) {

        for (Map<String, Object> order : orders) {
            List<Map<String, Object>> items = new ArrayList<>();

            ps.setInt(1, (Integer) order.get("orderId"));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();

                    item.put("itemName", rs.getString("itemName"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("imagePath", rs.getString("imagePath"));

                    items.add(item);
                }
            }

            order.put("items", items);
        }
    } catch (SQLException e) {
        throw new ServletException("Unable to load ordered items.", e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>My Orders | Midnight Cravings</title>

    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #FFFDF7;
            color: #29251F;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        .page {
            max-width: 1050px;
            margin: 45px auto;
            padding: 0 22px 50px;
        }

        .heading {
            margin-bottom: 25px;
        }

        .heading h1 {
            margin: 0 0 8px;
            font-size: 30px;
            font-weight: 800;
        }

        .heading p {
            color: #777166;
            margin: 0;
            font-size: 14px;
        }

        .notice {
            padding: 14px 17px;
            border-radius: 11px;
            margin: 0 0 22px;
            font-size: 13px;
            font-weight: 600;
            line-height: 1.6;
        }

        .notice.warning {
            background: #FFF1C7;
            color: #795900;
            border: 1px solid #F3D989;
        }

        .notice.success {
            background: #E4F6E8;
            color: #246B36;
            border: 1px solid #BCE5C5;
        }

        .filters {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 24px;
        }

        .filter-btn {
            border: 1px solid #E9DFCC;
            background: #FFFFFF;
            color: #625B50;
            padding: 10px 17px;
            border-radius: 24px;
            font-family: inherit;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s ease, color 0.2s ease;
        }

        .filter-btn:hover {
            border-color: #FFC025;
        }

        .filter-btn.active {
            background: #FFC025;
            color: #29251F;
            border-color: #FFC025;
        }

        .order-card {
            background: #FFFFFF;
            border: 1px solid #F0E7D5;
            border-radius: 17px;
            padding: 22px;
            margin-bottom: 18px;
            box-shadow: 0 5px 18px rgba(65, 49, 15, 0.04);
            transition: box-shadow 0.2s ease, transform 0.2s ease;
        }

        .order-card:hover {
            box-shadow: 0 8px 24px rgba(65, 49, 15, 0.08);
            transform: translateY(-2px);
        }

        .order-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            flex-wrap: wrap;
            padding-bottom: 17px;
            border-bottom: 1px solid #F0EADF;
        }

        .order-number {
            font-size: 17px;
            font-weight: 800;
        }

        .order-date {
            margin-top: 6px;
            font-size: 12px;
            color: #827B70;
        }

        .status {
            display: inline-block;
            background: #FFF1C7;
            color: #795900;
            padding: 8px 13px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 800;
        }

        .status.delivered {
            background: #E4F6E8;
            color: #246B36;
        }

        .status.rejected {
            background: #FCE7E5;
            color: #A52B22;
        }

        .status.pending {
            background: #FFF1C7;
            color: #795900;
        }

        .restaurant-info {
            padding: 17px 0;
            border-bottom: 1px solid #F0EADF;
        }

        .restaurant-label,
        .items-label {
            color: #827B70;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 7px;
        }

        .restaurant-name {
            font-size: 16px;
            font-weight: 800;
        }

        .items-section {
            padding: 16px 0 2px;
        }

        .items-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        /* Each ordered dish: image, name, and quantity. */
        .items-list li {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            padding: 11px 0;
            border-bottom: 1px solid #F5F0E5;
        }

        .items-list li:last-child {
            border-bottom: none;
        }

        .ordered-item-main {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .ordered-item-image {
            width: 64px;
            height: 64px;
            border-radius: 12px;
            object-fit: cover;
            flex-shrink: 0;
            background: #FFF7E2;
            border: 1px solid #F0E7D5;
        }

        .ordered-item-image.image-hidden {
            display: none;
        }

        .item-name {
            color: #494239;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .item-quantity {
            color: #827B70;
            font-weight: 700;
            font-size: 12px;
            white-space: nowrap;
            flex-shrink: 0;
        }

        .no-items {
            font-size: 13px;
            color: #827B70;
            margin: 0;
        }

        .order-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
            padding-top: 17px;
        }

        .payment-label,
        .total-label {
            color: #827B70;
            font-size: 12px;
            margin-bottom: 5px;
        }

        .payment-value {
            font-size: 14px;
            font-weight: 700;
        }

        .total-value {
            font-size: 20px;
            font-weight: 800;
        }

        .order-actions {
            margin-top: 18px;
            border-top: 1px solid #F0EADF;
            padding-top: 16px;
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .button {
            display: inline-block;
            padding: 12px 20px;
            background: #FFC025;
            color: #29251F;
            text-decoration: none;
            font-family: inherit;
            font-weight: 800;
            font-size: 13px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            text-align: center;
            transition: background 0.2s ease;
        }

        .button:hover {
            background: #F0B20F;
        }

        .button.secondary {
            background: #FFFFFF;
            border: 1px solid #E9DFCC;
        }

        .button.secondary:hover {
            background: #FFF7E2;
        }

        .order-actions form {
            margin: 0;
        }

        .empty {
            text-align: center;
            padding: 55px 22px;
            background: #FFFFFF;
            border: 1px solid #F0E7D5;
            border-radius: 18px;
        }

        .empty-icon {
            width: 76px;
            height: 76px;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #FFF1C7;
            border-radius: 50%;
            font-size: 34px;
        }

        .empty h2 {
            margin-top: 0;
        }

        .empty p {
            color: #777166;
            line-height: 1.7;
        }

        .empty .button {
            margin-top: 15px;
        }

        .filter-empty {
            display: none;
        }

        @media (max-width: 480px) {
            .page {
                margin-top: 28px;
                padding: 0 14px 35px;
            }

            .heading h1 {
                font-size: 25px;
            }

            .order-card {
                padding: 17px;
            }

            .filters {
                gap: 8px;
            }

            .filter-btn {
                padding: 9px 12px;
                font-size: 12px;
            }

            .ordered-item-image {
                width: 54px;
                height: 54px;
            }

            .ordered-item-main {
                gap: 9px;
            }

            .items-list li {
                gap: 8px;
            }

            .order-actions {
                flex-direction: column;
                align-items: stretch;
            }

            .order-actions .button,
            .order-actions form,
            .order-actions form .button {
                width: 100%;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="navbar.jsp" />

    <main class="page">

        <div class="heading">
            <h1>My Orders</h1>
            <p>Track your orders and revisit your order history.</p>
        </div>

        <%
            String reorderMessage = request.getParameter("reorder");
            String message = null;
            String messageType = "warning";

            if ("cart-not-empty".equals(reorderMessage)) {
                message = "Your cart already contains items. Please clear your cart before reordering.";
            } else if ("unavailable".equals(reorderMessage)) {
                message = "Some items from this order are no longer available. Please choose another order.";
            } else if ("not-found".equals(reorderMessage)) {
                message = "Order not found or you do not have permission to reorder it.";
            } else if ("no-items".equals(reorderMessage)) {
                message = "No items were found in this order.";
            } else if ("invalid".equals(reorderMessage)
                    || "invalid-items".equals(reorderMessage)) {
                message = "Unable to reorder this order. Please try again.";
            } else if ("success".equals(reorderMessage)) {
                message = "Your previous order has been added to your cart.";
                messageType = "success";
            } else if ("error".equals(reorderMessage)) {
                message = "Something went wrong while reordering. Please try again.";
            }

            if (message != null) {
        %>
            <div class="notice <%= messageType %>">
                <%= escapeHtml(message) %>
            </div>
        <%
            }
        %>

        <% if (orders.isEmpty()) { %>

            <div class="empty">
                <div class="empty-icon">&#127828;</div>
                <h2>No orders yet</h2>
                <p>
                    Your food journey starts here.
                    Explore our restaurants and place your first order!
                </p>

                <a class="button" href="<%= contextPath %>/home">
                    Explore Restaurants
                </a>
            </div>

        <% } else { %>

            <div class="filters" role="group" aria-label="Filter orders">
                <button type="button" class="filter-btn active"
                        data-filter="all">All Orders</button>

                <button type="button" class="filter-btn"
                        data-filter="active">Active</button>

                <button type="button" class="filter-btn"
                        data-filter="delivered">Delivered</button>

                <button type="button" class="filter-btn"
                        data-filter="rejected">Rejected</button>
            </div>

            <div id="ordersList">

                <% for (Map<String, Object> order : orders) {

                    int orderId = (Integer) order.get("orderId");

                    Timestamp orderDate =
                        (Timestamp) order.get("orderDate");

                    BigDecimal total =
                        (BigDecimal) order.get("totalAmount");

                    String status = (String) order.get("status");

                    String paymentMethod =
                        (String) order.get("paymentMethod");

                    String restaurantName =
                        (String) order.get("restaurantName");

                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> items =
                        (List<Map<String, Object>>) order.get("items");

                    String safeStatus = status != null
                        ? status.trim()
                        : "Unknown";

                    String statusClass = "";

                    if ("Delivered".equalsIgnoreCase(safeStatus)) {
                        statusClass = "delivered";
                    } else if ("Rejected".equalsIgnoreCase(safeStatus)) {
                        statusClass = "rejected";
                    } else if ("Pending".equalsIgnoreCase(safeStatus)) {
                        statusClass = "pending";
                    }

                    String filterStatus;

                    if ("Delivered".equalsIgnoreCase(safeStatus)) {
                        filterStatus = "delivered";
                    } else if ("Rejected".equalsIgnoreCase(safeStatus)) {
                        filterStatus = "rejected";
                    } else {
                        filterStatus = "active";
                    }
                %>

                    <section class="order-card"
                             data-status="<%= filterStatus %>">

                        <div class="order-top">

                            <div>
                                <div class="order-number">
                                    Order #<%= orderId %>
                                </div>

                                <div class="order-date">
                                    <%= orderDate != null
                                        ? orderDate.toLocalDateTime().format(
                                            java.time.format.DateTimeFormatter
                                                .ofPattern("dd MMM yyyy, hh:mm a")
                                          )
                                        : "Date unavailable" %>
                                </div>
                            </div>

                            <span class="status <%= statusClass %>">
                                <%= escapeHtml(safeStatus) %>
                            </span>

                        </div>

                        <div class="restaurant-info">
                            <div class="restaurant-label">
                                Restaurant
                            </div>

                            <div class="restaurant-name">
                                <%= restaurantName != null
                                    ? escapeHtml(restaurantName)
                                    : "Restaurant unavailable" %>
                            </div>
                        </div>

                        <div class="items-section">
                            <div class="items-label">
                                Items ordered
                            </div>

                            <% if (items != null && !items.isEmpty()) { %>

                                <ul class="items-list">

                                    <% for (Map<String, Object> item : items) {

                                        String itemName =
                                            String.valueOf(item.get("itemName"));

                                        Object imagePath =
                                            item.get("imagePath");

                                        int quantity =
                                            (Integer) item.get("quantity");

                                        String imageUrl =
                                            getImageUrl(imagePath);

                                        boolean hasImage =
                                            imageUrl != null &&
                                            !imageUrl.trim().isEmpty();
                                    %>

                                        <li>
                                            <div class="ordered-item-main">

                                                <% if (hasImage) { %>
                                                    <img
                                                        src="<%= contextPath %>/midnight_cravings_images/<%= escapeHtml(imageUrl) %>"
                                                        alt="<%= escapeHtml(itemName) %>"
                                                        class="ordered-item-image"
                                                        loading="lazy"
                                                        onerror="this.classList.add('image-hidden');"
                                                    >
                                                <% } %>

                                                <span class="item-name">
                                                    <%= escapeHtml(itemName) %>
                                                </span>

                                            </div>

                                            <span class="item-quantity">
                                                Qty: <%= quantity %>
                                            </span>
                                        </li>

                                    <% } %>

                                </ul>

                            <% } else { %>

                                <p class="no-items">
                                    Item details are unavailable for this order.
                                </p>

                            <% } %>
                        </div>

                        <div class="order-bottom">

                            <div>
                                <div class="payment-label">
                                    Payment method
                                </div>

                                <div class="payment-value">
                                    <%= "COD".equalsIgnoreCase(paymentMethod)
                                        ? "Cash on Delivery"
                                        : paymentMethod != null
                                            ? escapeHtml(paymentMethod)
                                            : "Not available" %>
                                </div>
                            </div>

                            <div>
                                <div class="total-label">
                                    Total amount
                                </div>

                                <div class="total-value">
                                    &#8377;<%= total != null
                                        ? total.toPlainString()
                                        : "0.00" %>
                                </div>
                            </div>

                        </div>

                        <div class="order-actions">

                            <% if (!"Rejected".equalsIgnoreCase(safeStatus)) { %>

                                <a class="button secondary"
                                   href="<%= contextPath %>/track-order?orderId=<%= orderId %>">
                                    Track Order &#8594;
                                </a>

                            <% } %>

                            <form action="<%= contextPath %>/reorder"
                                  method="post">

                                <input type="hidden"
                                       name="orderId"
                                       value="<%= orderId %>">

                                <button type="submit" class="button">
                                    Reorder
                                </button>

                            </form>

                        </div>

                    </section>

                <% } %>

                <div id="filterEmpty" class="empty filter-empty">
                    <h2>No orders in this category</h2>
                    <p>Try selecting another filter to see your orders.</p>
                </div>

            </div>

        <% } %>

    </main>

    <script>
        const filterButtons = document.querySelectorAll(".filter-btn");
        const orderCards = document.querySelectorAll(".order-card");
        const filterEmpty = document.getElementById("filterEmpty");

        filterButtons.forEach(function(button) {
            button.addEventListener("click", function() {
                const selectedFilter = this.dataset.filter;
                let visibleCount = 0;

                filterButtons.forEach(function(item) {
                    item.classList.remove("active");
                });

                this.classList.add("active");

                orderCards.forEach(function(card) {
                    const orderStatus = card.dataset.status;

                    const shouldShow =
                        selectedFilter === "all" ||
                        selectedFilter === orderStatus;

                    card.style.display = shouldShow ? "" : "none";

                    if (shouldShow) {
                        visibleCount++;
                    }
                });

                if (filterEmpty) {
                    filterEmpty.style.display =
                        visibleCount === 0 ? "block" : "none";
                }
            });
        });
    </script>

</body>
</html>
