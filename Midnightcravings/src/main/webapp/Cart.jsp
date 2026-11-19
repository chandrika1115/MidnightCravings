
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map"%>
<%@ page import="com.tap.Model.Cart"%>
<%@ page import="com.tap.Model.CartItem"%>
<%@ page import="java.text.DecimalFormat"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart | Midnight Cravings</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        :root {
            --bg-cream: #FFFDF7;
            --bg-card: #FFFFFF;
            --primary-yellow: #FFC025;
            --yellow-hover: #F0B41F;
            --text-dark: #1E1E1E;
            --text-muted: #6C727F;
            --border-light: #F0EAE1;
            --shadow-sm: 0 4px 12px rgba(0,0,0,0.04);
            --font-hand: 'Caveat', cursive;
            --font-sans: 'Plus Jakarta Sans', sans-serif;
            --danger-red: #C62828;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg-cream);
            font-family: var(--font-sans);
            color: var(--text-dark);
            line-height: 1.5;
            overflow-x: hidden;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        button {
            font-family: inherit;
        }

        .container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 24px;
        }

        .page-title {
            font-family: var(--font-hand);
            font-size: 42px;
            margin: 32px 0 24px;
            font-weight: 700;
        }

        .cart-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 320px;
            gap: 28px;
            align-items: start;
            margin-bottom: 60px;
        }

        .cart-card,
        .summary-card {
            background: var(--bg-card);
            border-radius: 20px;
            padding: 24px;
            box-shadow: var(--shadow-sm);
            min-width: 0;
        }

        .cart-table {
            width: 100%;
            border-collapse: collapse;
        }

        .cart-table th {
            text-align: left;
            color: var(--text-muted);
            font-size: 12px;
            text-transform: uppercase;
            padding: 0 8px 16px 0;
            border-bottom: 1px solid var(--border-light);
            letter-spacing: 0.4px;
            white-space: nowrap;
        }

        .cart-table td {
            padding: 20px 8px 20px 0;
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }

        .cart-table tr:last-child td {
            border-bottom: none;
        }

        /* FOOD IMAGE */

        .cart-item-image {
            display: block;
            width: 76px;
            height: 76px;
            object-fit: cover;
            border-radius: 12px;
            background: #FFF5D6;
        }

        .cart-item-image-placeholder {
            width: 76px;
            height: 76px;
            border-radius: 12px;
            background: #FFF5D6;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 5px;
            color: var(--text-muted);
            font-size: 10px;
        }

        .item-title {
            font-weight: 700;
            font-size: 14px;
            color: var(--text-dark);
            min-width: 120px;
        }

        .item-unit-price {
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 4px;
            white-space: nowrap;
        }

        .item-subtotal {
            font-weight: 800;
            white-space: nowrap;
        }

        .qty-btn-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #FFFFFF;
            border: 1.5px solid var(--primary-yellow);
            border-radius: 10px;
            width: 100px;
            height: 36px;
            padding: 0 4px;
        }

        .qty-btn-action {
            background: transparent;
            border: none;
            color: var(--text-dark);
            font-size: 17px;
            font-weight: 800;
            cursor: pointer;
            width: 28px;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
        }

        .qty-btn-action:hover {
            background: #FFF5D6;
        }

        .qty-display-num {
            color: var(--text-dark);
            font-weight: 800;
            font-size: 14px;
            min-width: 20px;
            text-align: center;
        }

        .remove-btn,
        .clear-cart-btn {
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 600;
            padding: 6px;
        }

        .remove-btn:hover {
            color: var(--danger-red);
        }

        .clear-cart-btn {
            text-decoration: underline;
            padding: 8px 0;
        }

        .clear-cart-btn:hover {
            color: var(--text-dark);
        }

        .summary-title {
            font-size: 20px;
            font-weight: 800;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border-light);
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 14px;
            font-size: 14px;
            color: var(--text-muted);
        }

        .summary-row span:last-child {
            color: var(--text-dark);
            white-space: nowrap;
        }

        .summary-row.total {
            font-size: 17px;
            font-weight: 800;
            color: var(--text-dark);
            border-top: 1px solid var(--border-light);
            padding-top: 16px;
            margin-top: 18px;
            margin-bottom: 0;
        }

        .checkout-btn,
        .browse-menu-btn {
            display: block;
            width: 100%;
            background: var(--primary-yellow);
            color: var(--text-dark);
            border: none;
            padding: 14px;
            border-radius: 12px;
            font-weight: 800;
            font-size: 15px;
            cursor: pointer;
            margin-top: 24px;
            text-align: center;
            transition: background 0.2s, transform 0.1s;
        }

        .checkout-btn:hover,
        .browse-menu-btn:hover {
            background: var(--yellow-hover);
        }

        .checkout-btn:active {
            transform: scale(0.98);
        }

        .continue-btn {
            display: inline-block;
            margin-top: 18px;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 13px;
        }

        .continue-btn:hover {
            color: var(--text-dark);
            text-decoration: underline;
        }

        .empty-cart {
            text-align: center;
            padding: 60px 20px;
            background: var(--bg-card);
            border-radius: 20px;
            box-shadow: var(--shadow-sm);
            margin-bottom: 60px;
        }

        .empty-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }

        .empty-cart h2 {
            font-size: 23px;
            font-weight: 800;
        }

        .empty-cart p {
            color: var(--text-muted);
            margin-top: 8px;
            font-size: 14px;
        }

        .browse-menu-btn {
            display: inline-block;
            width: auto;
            margin-top: 22px;
            padding: 12px 24px;
        }

        .cart-message {
            display: none;
            margin-bottom: 16px;
            padding: 12px;
            background: #FFF5D6;
            border-radius: 10px;
            color: var(--text-dark);
            font-size: 13px;
        }

        @media (max-width: 850px) {
            .cart-grid {
                grid-template-columns: minmax(0, 1fr);
                gap: 20px;
            }

            .summary-card {
                width: 100%;
            }
        }

        @media (max-width: 600px) {
            .container {
                padding: 0 16px;
            }

            .page-title {
                font-size: 36px;
                margin-top: 24px;
            }

            .cart-card {
                padding: 16px;
                overflow-x: auto;
            }

            .cart-table {
                min-width: 610px;
            }

            .summary-card {
                padding: 20px;
            }

            .empty-cart {
                padding: 45px 16px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="navbar.jsp" />

    <main class="container">

        <h1 class="page-title">Your Food Cart</h1>

        <div id="cartMessage" class="cart-message" role="status"></div>

        <%
            Cart cart = (Cart) session.getAttribute("cart");

            if (cart != null && cart.getItems() != null
                    && !cart.getItems().isEmpty()) {

                Map<Integer, CartItem> items = cart.getItems();
                double grandTotal = 0;
                DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
        %>

        <div class="cart-grid">

            <section class="cart-card" aria-label="Cart items">

                <table class="cart-table">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Item</th>
                            <th>Quantity</th>
                            <th>Subtotal</th>
                            <th style="text-align:center;">Action</th>
                        </tr>
                    </thead>

                    <tbody>
                    <%
                        for (CartItem item : items.values()) {
                            double itemTotal =
                                    item.getPrice() * item.getQuantity();
                            grandTotal += itemTotal;

                            String imagePath = item.getImagePath();
                            String imageUrl = "";

                            if (imagePath != null && !imagePath.trim().isEmpty()) {
                                imagePath = imagePath.trim().replace("\\", "/");

                                // Database path example: Neonclub/BBQ_pizza.jpg
                                // Files are inside webapp/midnight_cravings_images/
                                imageUrl = request.getContextPath()
                                        + "/midnight_cravings_images/"
                                        + imagePath;
                            }
                    %>

                        <tr>
                            <td>
                                <% if (!imageUrl.isEmpty()) { %>
                                    <img
                                        src="<%= imageUrl %>"
                                        alt="<%= item.getName() %>"
                                        class="cart-item-image"
                                        onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">

                                    <div class="cart-item-image-placeholder"
                                         style="display:none;">
                                        Image unavailable
                                    </div>
                                <% } else { %>
                                    <div class="cart-item-image-placeholder">
                                        No image
                                    </div>
                                <% } %>
                            </td>

                            <td>
                                <div class="item-title">
                                    <%= item.getName() %>
                                </div>

                                <div class="item-unit-price">
                                    ₹<%= moneyFormat.format(item.getPrice()) %> each
                                </div>
                            </td>

                            <td>
                                <div class="qty-btn-container">
                                    <button type="button"
                                            class="qty-btn-action"
                                            aria-label="Decrease <%= item.getName() %> quantity"
                                            onclick="updateCartQty(<%= item.getMenuId() %>, <%= item.getQuantity() - 1 %>)">
                                        −
                                    </button>

                                    <span class="qty-display-num">
                                        <%= item.getQuantity() %>
                                    </span>

                                    <button type="button"
                                            class="qty-btn-action"
                                            aria-label="Increase <%= item.getName() %> quantity"
                                            onclick="updateCartQty(<%= item.getMenuId() %>, <%= item.getQuantity() + 1 %>)">
                                        +
                                    </button>
                                </div>
                            </td>

                            <td class="item-subtotal">
                                ₹<%= moneyFormat.format(itemTotal) %>
                            </td>

                            <td style="text-align:center;">
                                <button type="button"
                                        class="remove-btn"
                                        onclick="updateCartQty(<%= item.getMenuId() %>, 0)"
                                        title="Remove item"
                                        aria-label="Remove <%= item.getName() %>">
                                    Remove
                                </button>
                            </td>
                        </tr>

                    <% } %>
                    </tbody>
                </table>

                <div style="margin-top:20px; text-align:right;">
                    <button type="button"
                            class="clear-cart-btn"
                            onclick="clearCart()">
                        Clear Entire Cart
                    </button>
                </div>

            </section>

            <aside class="summary-card">
                <h2 class="summary-title">Bill Details</h2>

                <div class="summary-row">
                    <span>Item Total</span>
                    <span>₹<%= moneyFormat.format(grandTotal) %></span>
                </div>

                <div class="summary-row">
                    <span>Delivery Fee</span>
                    <span>₹40.00</span>
                </div>

                <div class="summary-row">
                    <span>Taxes &amp; Charges</span>
                    <span>₹15.00</span>
                </div>

                <div class="summary-row total">
                    <span>To Pay</span>
                    <span>₹<%= moneyFormat.format(grandTotal + 40 + 15) %></span>
                </div>

                <button type="button"
                        class="checkout-btn"
                        onclick="window.location.href='checkout.jsp'">
                    Proceed to Checkout
                </button>

                <div style="text-align:center;">
                    <a href="restaurants" class="continue-btn">
                        ← Add more items
                    </a>
                </div>
            </aside>

        </div>

        <% } else { %>

        <section class="empty-cart">
            <div class="empty-icon" aria-hidden="true">🛒</div>
            <h2>Your cart is empty</h2>
            <p>Looks like you haven't added anything to your cart yet.</p>

            <a href="restaurants" class="browse-menu-btn">
                Explore Restaurants
            </a>
        </section>

        <% } %>

    </main>

    <jsp:include page="footer.jsp" />

    <script>
        function updateCartQty(menuId, newQty) {
            const formData = new URLSearchParams();

            formData.append('action', newQty <= 0 ? 'remove' : 'update');
            formData.append('menuId', menuId);
            formData.append('quantity', newQty);

            fetch('cart', {
                method: 'POST',
                headers: {
                    'Content-Type':
                        'application/x-www-form-urlencoded;charset=UTF-8'
                },
                body: formData.toString()
            })
            .then(async response => {
                if (!response.ok) {
                    const message = await response.text();
                    throw new Error(message || 'Could not update the cart.');
                }

                window.location.reload();
            })
            .catch(error => {
                console.error('Error updating cart:', error);
                showCartMessage('Unable to update your cart. Please try again.');
            });
        }

        function clearCart() {
            if (!confirm('Are you sure you want to clear your cart?')) {
                return;
            }

            const formData = new URLSearchParams();
            formData.append('action', 'clear');

            fetch('cart', {
                method: 'POST',
                headers: {
                    'Content-Type':
                        'application/x-www-form-urlencoded;charset=UTF-8'
                },
                body: formData.toString()
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Could not clear the cart.');
                }

                window.location.reload();
            })
            .catch(error => {
                console.error('Error clearing cart:', error);
                showCartMessage('Unable to clear your cart. Please try again.');
            });
        }

        function showCartMessage(message) {
            const messageElement = document.getElementById('cartMessage');

            if (messageElement) {
                messageElement.textContent = message;
                messageElement.style.display = 'block';
            }
        }
    </script>

</body>
</html>
