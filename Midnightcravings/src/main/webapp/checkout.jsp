
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map"%>
<%@ page import="com.tap.Model.Cart"%>
<%@ page import="com.tap.Model.CartItem"%>
<%@ page import="java.text.DecimalFormat"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        session.setAttribute(
            "redirectAfterLogin",
            request.getContextPath() + "/checkout.jsp"
        );

        response.sendRedirect(
            request.getContextPath() + "/Login.jsp"
        );
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | Midnight Cravings</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        :root {
            --cream: #FFFDF7;
            --yellow: #FFC025;
            --yellow-hover: #F0B41F;
            --dark: #1E1E1E;
            --muted: #6C727F;
            --border: #F0EAE1;
            --white: #FFFFFF;
            --shadow: 0 4px 12px rgba(0,0,0,0.04);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background: var(--cream);
            color: var(--dark);
            font-family: 'Plus Jakarta Sans', sans-serif;
            line-height: 1.6;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .container {
            max-width: 1050px;
            margin: auto;
            padding: 0 24px;
        }

        .page-title {
            font-family: 'Caveat', cursive;
            font-size: 44px;
            margin: 30px 0 6px;
        }

        .page-subtitle {
            color: var(--muted);
            margin-bottom: 26px;
        }

        .checkout-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 350px;
            gap: 25px;
            align-items: start;
            margin-bottom: 60px;
        }

        .panel {
            background: var(--white);
            border-radius: 18px;
            padding: 25px;
            box-shadow: var(--shadow);
            min-width: 0;
        }

        .panel h2 {
            font-size: 19px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 17px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 7px;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 12px 13px;
            font: inherit;
            font-size: 14px;
            background: #FFFEFB;
            color: var(--dark);
            outline: none;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            border-color: var(--yellow);
            box-shadow: 0 0 0 3px rgba(255,192,37,0.15);
        }

        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }

        .payment-option {
            display: flex;
            gap: 12px;
            align-items: center;
            border: 1.5px solid var(--yellow);
            border-radius: 12px;
            padding: 15px;
            background: #FFFCF2;
        }

        .payment-option input {
            accent-color: #B57C00;
            width: 17px;
            height: 17px;
        }

        .payment-option label {
            cursor: pointer;
            font-weight: 700;
        }

        .payment-option p {
            color: var(--muted);
            font-size: 12px;
            margin-top: 3px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin: 14px 0;
            font-size: 14px;
        }

        .summary-row span:first-child {
            color: var(--muted);
        }

        .summary-row span:last-child {
            font-weight: 600;
            white-space: nowrap;
        }

        .summary-divider {
            border: 0;
            border-top: 1px solid var(--border);
            margin: 18px 0;
        }

        .total-row {
            font-size: 17px;
            font-weight: 800;
        }

        .total-row span:first-child {
            color: var(--dark);
        }

        .item-line {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            font-size: 13px;
            margin-bottom: 12px;
        }

        .item-line .item-name {
            overflow-wrap: anywhere;
        }

        .item-line .item-price {
            white-space: nowrap;
            font-weight: 700;
        }

        .place-order-btn {
            display: block;
            width: 100%;
            margin-top: 23px;
            border: none;
            border-radius: 12px;
            padding: 15px;
            background: var(--yellow);
            color: var(--dark);
            font: inherit;
            font-weight: 800;
            cursor: pointer;
        }

        .place-order-btn:hover {
            background: var(--yellow-hover);
        }

        .back-link {
            display: inline-block;
            margin-top: 18px;
            font-size: 13px;
            font-weight: 700;
            color: var(--muted);
        }

        .back-link:hover {
            color: var(--dark);
            text-decoration: underline;
        }

        .empty-state {
            background: var(--white);
            border-radius: 18px;
            padding: 45px 20px;
            text-align: center;
            margin-bottom: 60px;
            box-shadow: var(--shadow);
        }

        .empty-state p {
            color: var(--muted);
            margin-top: 8px;
        }

        .browse-btn {
            display: inline-block;
            background: var(--yellow);
            border-radius: 10px;
            padding: 12px 20px;
            margin-top: 20px;
            font-weight: 800;
        }

        @media (max-width: 800px) {
            .checkout-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 600px) {
            .container {
                padding: 0 16px;
            }

            .page-title {
                font-size: 37px;
            }

            .panel {
                padding: 19px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="navbar.jsp" />

    <main class="container">
        <h1 class="page-title">Checkout</h1>
        <p class="page-subtitle">
            Almost there! Confirm your delivery details and review your order.
        </p>

        <%
            Cart cart = (Cart) session.getAttribute("cart");

            if (cart != null && cart.getItems() != null
                    && !cart.getItems().isEmpty()) {

                Map<Integer, CartItem> items = cart.getItems();
                double itemTotal = 0;
                DecimalFormat money = new DecimalFormat("#,##0.00");

                for (CartItem item : items.values()) {
                    itemTotal += item.getPrice() * item.getQuantity();
                }

                double deliveryFee = 40.00;
                double taxes = 15.00;
                double grandTotal = itemTotal + deliveryFee + taxes;
        %>

        <form action="<%= request.getContextPath() %>/place-order"
              method="post">

            <div class="checkout-grid">

                <section class="panel">
                    <h2>Delivery Details</h2>

                    <div class="form-group">
                        <label for="customerName">Full Name</label>
                        <input type="text"
                               id="customerName"
                               name="customerName"
                               maxlength="100"
                               autocomplete="name"
                               required
                               placeholder="Enter your full name">
                    </div>

                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel"
                               id="phone"
                               name="phone"
                               pattern="[0-9]{10}"
                               maxlength="10"
                               minlength="10"
                               inputmode="numeric"
                               autocomplete="tel"
                               required
                               placeholder="10-digit mobile number">
                    </div>

                    <div class="form-group">
                        <label for="address">Delivery Address</label>
                        <textarea id="address"
                                  name="address"
                                  maxlength="500"
                                  autocomplete="street-address"
                                  required
                                  placeholder="House number, street, area, city and PIN code"></textarea>
                    </div>

                    <h2 style="margin-top:28px;">Payment Method</h2>

                    <div class="payment-option">
                        <input type="radio"
                               id="cod"
                               name="paymentMethod"
                               value="COD"
                               checked
                               required>

                        <div>
                            <label for="cod">Cash on Delivery</label>
                            <p>Pay when your order arrives.</p>
                        </div>
                    </div>
                </section>

                <aside class="panel">
                    <h2>Order Summary</h2>

                    <% for (CartItem item : items.values()) {
                        double lineTotal =
                                item.getPrice() * item.getQuantity();
                    %>

                    <div class="item-line">
                        <span class="item-name">
                            <%= item.getName() %> × <%= item.getQuantity() %>
                        </span>
                        <span class="item-price">
                            ₹<%= money.format(lineTotal) %>
                        </span>
                    </div>

                    <% } %>

                    <hr class="summary-divider">

                    <div class="summary-row">
                        <span>Item Total</span>
                        <span>₹<%= money.format(itemTotal) %></span>
                    </div>

                    <div class="summary-row">
                        <span>Delivery Fee</span>
                        <span>₹<%= money.format(deliveryFee) %></span>
                    </div>

                    <div class="summary-row">
                        <span>Taxes &amp; Charges</span>
                        <span>₹<%= money.format(taxes) %></span>
                    </div>

                    <hr class="summary-divider">

                    <div class="summary-row total-row">
                        <span>To Pay</span>
                        <span>₹<%= money.format(grandTotal) %></span>
                    </div>

                    <button type="submit" class="place-order-btn">
                        Place Order · ₹<%= money.format(grandTotal) %>
                    </button>

                    <a href="<%= request.getContextPath() %>/cart"
                       class="back-link">
                        ← Back to Cart
                    </a>
                </aside>

            </div>
        </form>

        <% } else { %>

        <section class="empty-state">
            <h2>Your cart is empty</h2>
            <p>Add some delicious items before checking out.</p>
            <a class="browse-btn"
               href="<%= request.getContextPath() %>/restaurants">
                Explore Restaurants
            </a>
        </section>

        <% } %>

    </main>

    <jsp:include page="footer.jsp" />

</body>
</html>
