
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.tap.utility.DBConnection" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    Integer orderId = (Integer) session.getAttribute("lastOrderId");

    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    if (orderId == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    BigDecimal totalAmount = null;
    String orderStatus = null;
    String paymentMethod = null;
    String deliveryAddress = null;

    Boolean lastOrderAssigned =
            (Boolean) session.getAttribute("lastOrderAssigned");

    String assignmentMessage =
            (String) session.getAttribute("assignmentMessage");

    String sql = "SELECT totalAmount, status, paymentMethod, deliveryAddress "
               + "FROM orders WHERE orderId = ? AND userId = ?";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, orderId);
        ps.setInt(2, userId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                totalAmount = rs.getBigDecimal("totalAmount");
                orderStatus = rs.getString("status");
                paymentMethod = rs.getString("paymentMethod");
                deliveryAddress = rs.getString("deliveryAddress");
            }
        }
    } catch (SQLException e) {
        throw new ServletException("Unable to retrieve order details.", e);
    }

    if (totalAmount == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    if (assignmentMessage == null || assignmentMessage.trim().isEmpty()) {
        assignmentMessage = "Your order has been received.";
    }

    boolean agentAssigned = Boolean.TRUE.equals(lastOrderAssigned);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed | Midnight Cravings</title>

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

        .container {
            max-width: 620px;
            margin: 65px auto;
            padding: 20px;
        }

        .card {
            background: #FFFFFF;
            border: 1px solid #F1E9D8;
            border-radius: 22px;
            padding: 38px 30px;
            text-align: center;
            box-shadow: 0 12px 35px rgba(70, 55, 20, 0.07);
        }

        .success-icon {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            background: #FFF0B8;
            color: #795900;
            font-size: 38px;
            font-weight: 800;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0 auto 22px;
        }

        h1 {
            font-size: 27px;
            margin: 0 0 12px;
        }

        .subtitle {
            color: #777166;
            line-height: 1.7;
            margin-bottom: 24px;
        }

        .assignment-notice {
            text-align: left;
            padding: 16px 18px;
            margin-bottom: 25px;
            border-radius: 13px;
            line-height: 1.7;
            font-size: 14px;
        }

        .assignment-notice.assigned {
            background: #FFF8DF;
            border: 1px solid #F2D982;
            color: #665014;
        }

        .assignment-notice.waiting {
            background: #FFF5E8;
            border: 1px solid #EED6B8;
            color: #765126;
        }

        .notice-title {
            display: block;
            font-weight: 800;
            margin-bottom: 5px;
        }

        .details {
            text-align: left;
            background: #FFFDF7;
            border-radius: 14px;
            padding: 20px;
            margin-bottom: 26px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            padding: 12px 0;
            border-bottom: 1px solid #EFE8DA;
            font-size: 14px;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .label {
            color: #777166;
        }

        .value {
            font-weight: 700;
            text-align: right;
            overflow-wrap: anywhere;
        }

        .address-row {
            display: block;
        }

        .address-row .value {
            display: block;
            text-align: left;
            margin-top: 8px;
        }

        .button {
            display: block;
            width: 100%;
            padding: 15px;
            background: #FFC025;
            color: #29251F;
            text-decoration: none;
            font-weight: 800;
            border-radius: 12px;
            transition: background 0.2s;
        }

        .button:hover {
            background: #F0B20F;
        }

        .secondary {
            display: inline-block;
            margin-top: 18px;
            color: #65583D;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
        }

        @media (max-width: 480px) {
            .container {
                margin: 25px auto;
            }

            .card {
                padding: 28px 18px;
            }

            h1 {
                font-size: 23px;
            }

            .detail-row {
                gap: 10px;
            }
        }
    </style>
</head>

<body>
    <main class="container">
        <section class="card">

            <div class="success-icon">&#10003;</div>

            <h1>Order placed successfully!</h1>

            <p class="subtitle">
                Thank you for choosing Midnight Cravings.
                Your order has been received.
            </p>

            <div class="assignment-notice <%= agentAssigned ? "assigned" : "waiting" %>">
                <span class="notice-title">
                    <%= agentAssigned
                        ? "Delivery agent assigned"
                        : "Waiting for a delivery agent" %>
                </span>

                <%= assignmentMessage %>
            </div>

            <div class="details">

                <div class="detail-row">
                    <span class="label">Order ID</span>
                    <span class="value">#<%= orderId %></span>
                </div>

                <div class="detail-row">
                    <span class="label">Order status</span>
                    <span class="value"><%= orderStatus %></span>
                </div>

                <div class="detail-row">
                    <span class="label">Payment method</span>
                    <span class="value">
                        <%= "COD".equalsIgnoreCase(paymentMethod)
                            ? "Cash on Delivery"
                            : paymentMethod %>
                    </span>
                </div>

                <div class="detail-row">
                    <span class="label">Total amount</span>
                    <span class="value">
                        ₹<%= totalAmount.toPlainString() %>
                    </span>
                </div>

                <div class="detail-row address-row">
                    <span class="label">Delivery address</span>
                    <span class="value">
                        <%= deliveryAddress == null
                            ? "Not provided"
                            : deliveryAddress %>
                    </span>
                </div>

            </div>

            <a class="button"
               href="<%= request.getContextPath() %>/home">
                Continue Shopping
            </a>

            <a class="secondary"
               href="<%= request.getContextPath() %>/home">
                Back to Home
            </a>

        </section>
    </main>
</body>
</html>
