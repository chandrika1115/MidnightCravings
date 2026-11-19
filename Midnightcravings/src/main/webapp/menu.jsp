
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.tap.Model.Restaurant"%>
<%@ page import="com.tap.Model.Menu"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu | Midnight Cravings</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

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
            --shadow-md: 0 8px 24px rgba(0,0,0,0.08);
            --font-hand: 'Caveat', cursive;
            --font-sans: 'Plus Jakarta Sans', sans-serif;
            --veg-green: #2E7D32;
            --non-veg-red: #C62828;
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

        button,
        input {
            font-family: inherit;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
        }

        /* RESTAURANT HEADER */

        .restaurant-header {
            background: #FFF9E6;
            border-radius: 28px;
            padding: 32px;
            margin: 32px 0;
            display: flex;
            align-items: center;
            gap: 32px;
            box-shadow: var(--shadow-sm);
        }

        .restaurant-header-img {
            width: 160px;
            height: 160px;
            flex-shrink: 0;
            border-radius: 20px;
            object-fit: cover;
            border: 4px solid white;
            box-shadow: var(--shadow-sm);
        }

        .restaurant-details h1 {
            font-size: 32px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .restaurant-meta {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            font-size: 14px;
            color: var(--text-muted);
            margin-top: 10px;
        }

        .rating-badge {
            background: #EAF7ED;
            color: #2E7D32;
            font-weight: 700;
            padding: 4px 8px;
            border-radius: 8px;
            font-size: 13px;
        }

        /* MENU SECTION */

        .menu-title-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
        }

        .section-title {
            font-family: var(--font-hand);
            font-size: 38px;
        }

        .menu-search {
            background: #F5F0E6;
            border: 1px solid transparent;
            padding: 10px 18px;
            border-radius: 20px;
            font-size: 14px;
            outline: none;
            width: 250px;
        }

        .menu-search:focus {
            border-color: var(--primary-yellow);
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 24px;
            margin-bottom: 60px;
            width: 100%;
        }

        .menu-card {
            background: var(--bg-card);
            border-radius: 20px;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s, box-shadow 0.2s;
            width: 100%;
            min-width: 0;
        }

        .menu-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-md);
        }

        .item-info {
            flex: 1;
            min-width: 0;
        }

        /* VEG / NON-VEG INDICATOR */

        .item-type {
            width: 14px;
            height: 14px;
            border: 2px solid var(--veg-green);
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 3px;
            margin-bottom: 8px;
        }

        .item-type::after {
            content: '';
            width: 6px;
            height: 6px;
            background-color: var(--veg-green);
            border-radius: 50%;
        }

        .menu-card.non-veg-item .item-type {
            border-color: var(--non-veg-red);
        }

        .menu-card.non-veg-item .item-type::after {
            background-color: var(--non-veg-red);
        }

        .item-name {
            font-size: 17px;
            font-weight: 700;
            margin-bottom: 4px;
            overflow-wrap: anywhere;
        }

        .item-price {
            font-size: 16px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .item-desc {
            font-size: 12px;
            color: var(--text-muted);
            line-height: 1.5;
        }

        .item-action {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            flex-shrink: 0;
            min-width: 120px;
        }

        .item-img {
            width: 120px;
            height: 110px;
            border-radius: 16px;
            object-fit: cover;
            background: #FFF5D6;
        }

        /* ADD BUTTON */

        .add-btn {
            background: var(--bg-card);
            color: var(--veg-green);
            border: 1px solid #D1E7DD;
            font-weight: 800;
            padding: 8px 24px;
            border-radius: 12px;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            font-size: 14px;
            text-transform: uppercase;
            transition: background-color 0.2s, transform 0.1s;
        }

        .add-btn:hover {
            background: var(--primary-yellow);
            color: var(--text-dark);
            border-color: var(--primary-yellow);
        }

        .add-btn:active {
            transform: scale(0.97);
        }

        /* QUANTITY CONTROLS */

        .qty-btn-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background-color: #FFFFFF;
            border: 1px solid var(--primary-yellow);
            border-radius: 12px;
            width: 100px;
            height: 36px;
            box-shadow: var(--shadow-sm);
            padding: 0 4px;
        }

        .qty-btn-action {
            background: transparent;
            border: none;
            color: var(--text-dark);
            font-weight: 800;
            font-size: 16px;
            width: 28px;
            height: 100%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
        }

        .qty-btn-action:hover {
            background-color: #FFF5D6;
        }

        .qty-display-num {
            font-weight: 800;
            font-size: 15px;
            color: var(--text-dark);
            display: inline-block;
            text-align: center;
            min-width: 20px;
        }

        /* RESTAURANT CHANGE MODAL */

        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(30, 30, 30, 0.48);
            display: none;
            align-items: center;
            justify-content: center;
            padding: 20px;
            z-index: 9999;
            backdrop-filter: blur(3px);
        }

        .modal-overlay.show {
            display: flex;
            animation: overlayFadeIn 0.2s ease;
        }

        .restaurant-modal {
            background: #FFFDF7;
            width: 100%;
            max-width: 420px;
            border-radius: 24px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0,0,0,0.18);
            animation: modalSlideIn 0.25s ease;
        }

        .modal-icon {
            width: 68px;
            height: 68px;
            margin: 0 auto 18px;
            border-radius: 22px;
            background: #FFF2CC;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
        }

        .modal-title {
            font-size: 23px;
            font-weight: 800;
            margin-bottom: 10px;
            color: var(--text-dark);
        }

        .modal-description {
            font-size: 14px;
            line-height: 1.7;
            color: var(--text-muted);
            margin-bottom: 24px;
        }

        .modal-btn {
            width: 100%;
            padding: 13px 16px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            transition: background 0.2s, transform 0.15s;
        }

        .modal-btn:active {
            transform: scale(0.98);
        }

        .modal-confirm-btn {
            border: none;
            background: var(--primary-yellow);
            color: var(--text-dark);
        }

        .modal-confirm-btn:hover {
            background: var(--yellow-hover);
        }

        .modal-cancel-btn {
            margin-top: 10px;
            border: 1px solid var(--border-light);
            background: #FFFFFF;
            color: var(--text-dark);
        }

        .modal-cancel-btn:hover {
            background: #FFF5D6;
        }

        .modal-btn:disabled {
            opacity: 0.65;
            cursor: not-allowed;
        }

        .cart-feedback {
            display: none;
            margin: 16px 0;
            padding: 12px 16px;
            border-radius: 12px;
            background: #FFF2CC;
            color: var(--text-dark);
            font-size: 13px;
        }

        .cart-feedback.show {
            display: block;
        }

        @keyframes overlayFadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(12px) scale(0.97);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* RESPONSIVE */

        @media (max-width: 900px) {
            .menu-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .restaurant-header {
                flex-direction: column;
                text-align: center;
                padding: 24px;
            }

            .restaurant-meta {
                justify-content: center;
            }

            .menu-title-row {
                flex-direction: column;
                align-items: flex-start;
            }

            .menu-search {
                width: 100%;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 0 16px;
            }

            .restaurant-header-img {
                width: 130px;
                height: 130px;
            }

            .restaurant-details h1 {
                font-size: 25px;
            }

            .section-title {
                font-size: 34px;
            }

            .menu-card {
                padding: 14px;
                gap: 12px;
            }

            .item-action {
                min-width: 95px;
            }

            .item-img {
                width: 100px;
                height: 95px;
            }

            .item-name {
                font-size: 15px;
            }

            .item-desc {
                font-size: 11px;
            }

            .restaurant-modal {
                padding: 25px 20px;
                border-radius: 20px;
            }

            .modal-title {
                font-size: 21px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="navbar.jsp" />

    <!-- RESTAURANT CHANGE MODAL -->
    <div class="modal-overlay"
         id="restaurantChangeModal"
         role="dialog"
         aria-modal="true"
         aria-labelledby="restaurantModalTitle"
         aria-describedby="restaurantModalDescription">

        <div class="restaurant-modal">

            <div class="modal-icon" aria-hidden="true">🛍️</div>

            <h2 class="modal-title" id="restaurantModalTitle">
                Start a new cart?
            </h2>

            <p class="modal-description" id="restaurantModalDescription">
                Your cart contains items from another restaurant.
                Would you like to clear your current cart and add
                this item instead?
            </p>

            <button type="button"
                    class="modal-btn modal-confirm-btn"
                    id="confirmRestaurantChange">
                Clear cart &amp; continue
            </button>

            <button type="button"
                    class="modal-btn modal-cancel-btn"
                    id="cancelRestaurantChange">
                Keep my cart
            </button>
        </div>
    </div>

    <main class="container">

        <%
            Restaurant restaurant =
                (Restaurant) request.getAttribute("restaurant");

            List<Menu> menuList =
                (List<Menu>) request.getAttribute("menuList");

            if (restaurant != null) {
        %>

        <!-- RESTAURANT HEADER -->
        <div class="restaurant-header">

            <img src="<%= request.getContextPath() %>/midnight_cravings_images/<%= restaurant.getImagePath() %>"
                 alt="<%= restaurant.getName() %>"
                 class="restaurant-header-img"
                 onerror="this.onerror=null; this.src='https://via.placeholder.com/160?text=Restaurant';">

            <div class="restaurant-details">

                <h1><%= restaurant.getName() %></h1>

                <p style="color: var(--text-muted); font-weight: 600;">
                    <%= restaurant.getCuisineType() %>
                </p>

                <div class="restaurant-meta">
                    <span class="rating-badge">
                        ★ <%= restaurant.getRating() %>
                    </span>

                    <span>
                        🕒 Opens: <%= restaurant.getOpeningTime() %>
                    </span>
                </div>

            </div>
        </div>

        <% } %>

        <div id="cartFeedback" class="cart-feedback" role="status"></div>

        <!-- MENU ITEMS -->
        <section>

            <div class="menu-title-row">
                <h2 class="section-title">Recommended Menu</h2>

                <input type="text"
                       id="menuSearch"
                       class="menu-search"
                       placeholder="Search in menu..."
                       aria-label="Search menu">
            </div>

            <div class="menu-grid" id="menuGrid">

                <%
                    if (menuList != null && !menuList.isEmpty()) {
                        for (Menu m : menuList) {
                %>

                <div class="menu-card">

                    <div class="item-info">

                        <div class="item-type" aria-hidden="true"></div>

                        <h3 class="item-name">
                            <%= m.getItemName() %>
                        </h3>

                        <div class="item-price">
                            ₹<%= m.getPrice() %>
                        </div>

                        <p class="item-desc">
                            <%= m.getDescription() != null
                                ? m.getDescription()
                                : "Delicious preparation with fresh ingredients." %>
                        </p>

                    </div>

                    <div class="item-action"
                         id="action-container-<%= m.getMenuId() %>">

                        <img src="<%= request.getContextPath() %>/midnight_cravings_images/<%= m.getImagePath() %>"
                             alt="<%= m.getItemName() %>"
                             class="item-img"
                             onerror="this.onerror=null; this.src='https://via.placeholder.com/120x110?text=Food+Item';">

                        <button type="button"
                                class="add-btn"
                                onclick="changeQuantity(<%= m.getMenuId() %>, 1)">
                            ADD
                        </button>

                    </div>

                </div>

                <%
                        }
                    } else {
                %>

                <p style="grid-column:1/-1; text-align:center; color:var(--text-muted); font-size:18px; margin:40px 0;">
                    No menu items found for this restaurant.
                </p>

                <%
                    }
                %>

            </div>
        </section>

    </main>

    <jsp:include page="footer.jsp" />

    <script>
        let pendingMenuId = null;
        let pendingQuantity = null;
        let cartRequestInProgress = false;

        document.addEventListener('DOMContentLoaded', function() {

            /*
             * VEG / NON-VEG DETECTION
             *
             * Do not classify "biryani" or "tikka" as non-veg by themselves.
             * Those dishes can be vegetarian or non-vegetarian.
             */
            const menuCards = document.querySelectorAll('.menu-card');

            const nonVegKeywords = [
                'chicken',
                'mutton',
                'fish',
                'prawn',
                'shrimp',
                'beef',
                'pork',
                'bacon',
                'seafood',
                'egg',
                'anda'
            ];

            const vegExceptions = [
                'eggless'
            ];

            menuCards.forEach(card => {
                const nameElement = card.querySelector('.item-name');
                const descElement = card.querySelector('.item-desc');

                if (!nameElement) return;

                const itemName = nameElement.textContent
                    .toLowerCase()
                    .trim();

                const description = descElement
                    ? descElement.textContent.toLowerCase()
                    : '';

                /*
                 * Use the item name for classification.
                 * Descriptions often contain generic words that can
                 * incorrectly mark a vegetarian dish as non-vegetarian.
                 */
                const hasVegException = vegExceptions.some(keyword =>
                    itemName.includes(keyword)
                );

                const isNonVeg = !hasVegException &&
                    nonVegKeywords.some(keyword =>
                        new RegExp('\\b' + keyword + '\\b', 'i').test(itemName)
                    );

                card.classList.toggle('non-veg-item', isNonVeg);
            });

            // Menu search filter.
            const menuSearch = document.getElementById('menuSearch');

            if (menuSearch) {
                menuSearch.addEventListener('input', function() {
                    const query = this.value.toLowerCase().trim();

                    menuCards.forEach(card => {
                        const name = card.querySelector('.item-name')
                            .textContent.toLowerCase();

                        const desc = card.querySelector('.item-desc')
                            .textContent.toLowerCase();

                        card.style.display =
                            name.includes(query) || desc.includes(query)
                                ? 'flex'
                                : 'none';
                    });
                });
            }

            // Modal buttons.
            document.getElementById('cancelRestaurantChange')
                .addEventListener('click', closeRestaurantChangeModal);

            document.getElementById('confirmRestaurantChange')
                .addEventListener('click', confirmRestaurantChange);

            // Clicking the dark backdrop closes the modal.
            document.getElementById('restaurantChangeModal')
                .addEventListener('click', function(event) {
                    if (event.target === this) {
                        closeRestaurantChangeModal();
                    }
                });

            // Escape closes the modal.
            document.addEventListener('keydown', function(event) {
                if (event.key === 'Escape') {
                    closeRestaurantChangeModal();
                }
            });

            updateCartBadge();
            syncCartButtons();
        });

        // Load current quantities from the session cart.
        function syncCartButtons() {
            fetch('cart?action=getCartItems')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Could not load cart items.');
                    }
                    return response.json();
                })
                .then(cartMap => {
                    for (const [menuId, qty] of Object.entries(cartMap)) {
                        renderQtyControl(menuId, Number(qty));
                    }
                })
                .catch(error => {
                    console.error('Error syncing cart buttons:', error);
                });
        }

        // Open the custom restaurant-change modal.
        function openRestaurantChangeModal(menuId, newQty) {
            pendingMenuId = menuId;
            pendingQuantity = newQty;

            const modal = document.getElementById('restaurantChangeModal');
            const confirmButton =
                document.getElementById('confirmRestaurantChange');

            confirmButton.disabled = false;
            confirmButton.textContent = 'Clear cart & continue';

            modal.classList.add('show');
            document.getElementById('cancelRestaurantChange').focus();
        }

        // Close the modal without changing the cart.
        function closeRestaurantChangeModal() {
            document.getElementById('restaurantChangeModal')
                .classList.remove('show');

            pendingMenuId = null;
            pendingQuantity = null;

            const confirmButton =
                document.getElementById('confirmRestaurantChange');

            confirmButton.disabled = false;
            confirmButton.textContent = 'Clear cart & continue';
        }

        // Clear the old restaurant cart and add the selected item.
        async function confirmRestaurantChange() {
            if (pendingMenuId === null || cartRequestInProgress) {
                return;
            }

            const menuId = pendingMenuId;
            const quantity = pendingQuantity;
            const button =
                document.getElementById('confirmRestaurantChange');

            cartRequestInProgress = true;
            button.disabled = true;
            button.textContent = 'Updating cart...';

            try {
                const clearData = new URLSearchParams();
                clearData.append('action', 'clear');

                const clearResponse = await fetch('cart', {
                    method: 'POST',
                    headers: {
                        'Content-Type':
                            'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: clearData.toString()
                });

                if (!clearResponse.ok) {
                    throw new Error('Could not clear your current cart.');
                }

                closeRestaurantChangeModal();

                await sendCartUpdate(menuId, quantity, true);

            } catch (error) {
                console.error('Cart replacement error:', error);

                showCartFeedback(
                    'We could not replace your cart. Please try again.'
                );
            } finally {
                cartRequestInProgress = false;
                button.disabled = false;
                button.textContent = 'Clear cart & continue';
            }
        }

        // Update quantity or add/remove an item.
        async function changeQuantity(menuId, newQty) {
            if (cartRequestInProgress) return;

            await sendCartUpdate(menuId, newQty, false);
        }

        async function sendCartUpdate(menuId, newQty, retryAfterClear) {
            const formData = new URLSearchParams();

            formData.append('action', newQty <= 0 ? 'remove' : 'update');
            formData.append('menuId', menuId);
            formData.append('quantity', newQty);

            try {
                const response = await fetch('cart', {
                    method: 'POST',
                    headers: {
                        'Content-Type':
                            'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: formData.toString()
                });

                const responseText = await response.text();

                if (response.status === 409) {
                    if (!retryAfterClear) {
                        openRestaurantChangeModal(menuId, newQty);
                    } else {
                        showCartFeedback(
                            'This item could not be added. Please try again.'
                        );
                    }
                    return;
                }

                if (!response.ok) {
                    console.error('Cart update failed:', responseText);

                    showCartFeedback(
                        'Unable to update your cart. Please try again.'
                    );
                    return;
                }

                renderQtyControl(menuId, newQty);
                await updateCartBadge();

            } catch (error) {
                console.error('Cart request error:', error);

                showCartFeedback(
                    'Unable to connect. Please check your connection and try again.'
                );
            }
        }

        // Display the quantity controls for a menu item.
        function renderQtyControl(menuId, qty) {
            const actionContainer =
                document.getElementById('action-container-' + menuId);

            if (!actionContainer) return;

            const imgElement = actionContainer.querySelector('.item-img');

            if (!imgElement) {
                console.error('Food image not found for menuId:', menuId);
                return;
            }

            const imageHTML = imgElement.outerHTML;
            actionContainer.innerHTML = imageHTML;

            if (qty <= 0) {
                const addButton = document.createElement('button');

                addButton.type = 'button';
                addButton.className = 'add-btn';
                addButton.textContent = 'ADD';

                addButton.addEventListener('click', function() {
                    changeQuantity(menuId, 1);
                });

                actionContainer.appendChild(addButton);
                return;
            }

            const controls = document.createElement('div');
            controls.className = 'qty-btn-container';

            const minusButton = document.createElement('button');
            minusButton.type = 'button';
            minusButton.className = 'qty-btn-action';
            minusButton.textContent = '−';
            minusButton.setAttribute('aria-label', 'Decrease quantity');

            minusButton.addEventListener('click', function() {
                changeQuantity(menuId, qty - 1);
            });

            const quantity = document.createElement('span');
            quantity.className = 'qty-display-num';
            quantity.textContent = qty;

            const plusButton = document.createElement('button');
            plusButton.type = 'button';
            plusButton.className = 'qty-btn-action';
            plusButton.textContent = '+';
            plusButton.setAttribute('aria-label', 'Increase quantity');

            plusButton.addEventListener('click', function() {
                changeQuantity(menuId, qty + 1);
            });

            controls.append(minusButton, quantity, plusButton);
            actionContainer.appendChild(controls);
        }

        // Refresh the cart count in the navbar.
        async function updateCartBadge() {
            try {
                const response = await fetch('cart?action=getCount');

                if (!response.ok) return;

                const count = await response.text();
                const badge = document.getElementById('cartCount');

                if (badge) {
                    badge.textContent = count;
                }
            } catch (error) {
                console.error('Error updating cart badge:', error);
            }
        }

        // Show a styled message for cart errors.
        function showCartFeedback(message) {
            const feedback = document.getElementById('cartFeedback');

            if (!feedback) return;

            feedback.textContent = message;
            feedback.classList.add('show');
        }
    </script>

</body>
</html>
