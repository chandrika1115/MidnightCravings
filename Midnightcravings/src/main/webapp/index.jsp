<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.tap.Model.Restaurant"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Midnight Cravings | Good Food • Happy Mood</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        :root {
            --bg-cream: #FFFDF7;
            --bg-card: #FFFFFF;
            --primary-yellow: #FFC025;
            --accent-orange: #FF5A1F;
            --text-dark: #1E1E1E;
            --text-muted: #6C727F;
            --border-light: #F0EAE1;
            --shadow-sm: 0 4px 12px rgba(0,0,0,0.04);
            --shadow-md: 0 8px 24px rgba(0,0,0,0.08);
            --font-hand: 'Caveat', cursive;
            --font-sans: 'Plus Jakarta Sans', sans-serif;
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
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
        }

        /* HERO SECTION */
        .hero-section {
            padding: 40px 0;
        }

        .hero-card {
            background: #FFF9E6;
            border-radius: 32px;
            padding: 48px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            align-items: center;
            gap: 40px;
            position: relative;
            overflow: hidden;
        }

        .hero-title {
            font-family: var(--font-hand);
            font-size: 54px;
            line-height: 1.1;
            color: var(--text-dark);
            margin-bottom: 16px;
        }

        .hero-title span {
            color: var(--primary-yellow);
            background: #1E1E1E;
            padding: 0 12px;
            border-radius: 8px;
            display: inline-block;
        }

        .hero-desc {
            color: var(--text-muted);
            font-size: 16px;
            margin-bottom: 28px;
            max-width: 380px;
        }

        .btn-primary {
            background: var(--primary-yellow);
            color: var(--text-dark);
            font-weight: 700;
            padding: 14px 28px;
            border-radius: 28px;
            border: none;
            cursor: pointer;
            font-size: 15px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: transform 0.2s, background-color 0.2s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            background-color: #F7B413;
        }

        .hero-img-container {
            position: relative;
            text-align: center;
        }

        .hero-img {
            width: 100%;
            max-width: 420px;
            height: 320px;
            object-fit: cover;
            border-radius: 50%;
            border: 8px solid white;
            box-shadow: var(--shadow-md);
        }

        .hero-tag {
            position: absolute;
            top: 10px;
            right: 20px;
            background: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-family: var(--font-hand);
            font-size: 20px;
            font-weight: bold;
            box-shadow: var(--shadow-sm);
            transform: rotate(6deg);
        }

        /* SHARED SECTION TITLES */
        .section-title {
            font-family: var(--font-hand);
            font-size: 36px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* CRAVING CATEGORIES */
        .cravings-grid {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 16px;
            margin-bottom: 50px;
        }

        .craving-card {
            background: #FFF9E8;
            border-radius: 20px;
            padding: 16px 12px;
            text-align: center;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            border: 2px solid transparent;
        }

        .craving-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-sm);
            border-color: var(--primary-yellow);
        }

        .craving-card.active {
            background: var(--primary-yellow);
        }

        .craving-img {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            object-fit: cover;
            margin: 0 auto 10px;
            display: block;
            box-shadow: 0 4px 8px rgba(0,0,0,0.08);
        }

        .craving-name {
            font-size: 14px;
            font-weight: 700;
        }

        /* RESTAURANTS */
        .restaurants-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .view-all {
            font-weight: 700;
            color: var(--text-dark);
            font-size: 14px;
        }

        .view-all:hover {
            color: #8A6500;
        }

        .restaurant-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 24px;
            margin-bottom: 60px;
        }

        .restaurant-card {
            background: var(--bg-card);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .restaurant-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-md);
        }

        .card-img-wrap {
            position: relative;
            height: 170px;
            width: 100%;
            background-color: #F5F0E6;
        }

        .card-img-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .badge {
            position: absolute;
            top: 12px;
            right: 12px;
            background: var(--primary-yellow);
            font-size: 11px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 12px;
            text-transform: uppercase;
        }

        .card-body {
            padding: 16px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .card-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 4px;
            gap: 8px;
        }

        .restaurant-name {
            font-size: 16px;
            font-weight: 700;
            overflow-wrap: anywhere;
        }

        .rating {
            background: #EAF7ED;
            color: #2E7D32;
            font-weight: 700;
            font-size: 12px;
            padding: 2px 6px;
            border-radius: 6px;
            white-space: nowrap;
        }

        .cuisine-tags {
            color: var(--text-muted);
            font-size: 12px;
            margin-bottom: 12px;
        }

        .card-footer-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
            padding-top: 10px;
            border-top: 1px dashed var(--border-light);
            font-size: 12px;
            color: var(--text-muted);
            gap: 8px;
        }

        .action-btn {
            width: 28px;
            height: 28px;
            background: #FFF3C4;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-dark);
            font-weight: bold;
            flex-shrink: 0;
        }

        .empty-restaurants {
            grid-column: 1 / -1;
            padding: 24px;
            color: var(--text-muted);
            text-align: center;
        }

        /* PROMO BANNER */
        .promo-banner {
            background: #1E1E1E;
            color: white;
            border-radius: 24px;
            padding: 36px 48px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
            margin-bottom: 60px;
            background-image: radial-gradient(#333 1px, transparent 1px);
            background-size: 16px 16px;
        }

        .promo-title {
            font-family: var(--font-hand);
            font-size: 40px;
            color: var(--primary-yellow);
            line-height: 1;
        }

        .promo-subtitle {
            font-size: 18px;
            margin-top: 8px;
        }

        /* WHY CHOOSE US */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 60px;
        }

        .feature-item {
            display: flex;
            align-items: center;
            gap: 14px;
            background: white;
            padding: 16px 20px;
            border-radius: 16px;
            box-shadow: var(--shadow-sm);
        }

        .feature-icon {
            width: 44px;
            height: 44px;
            background: #FFF9E6;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .feature-title {
            font-size: 14px;
            font-weight: 700;
        }

        .feature-desc {
            font-size: 11px;
            color: var(--text-muted);
        }

        /* FOOTER */
        footer {
            background: var(--primary-yellow);
            padding: 24px 16px;
            text-align: center;
            font-family: var(--font-hand);
            font-size: 24px;
            font-weight: 700;
        }

        /* RESPONSIVE */
        @media (max-width: 1024px) {
            .restaurant-grid {
                grid-template-columns: repeat(3, 1fr);
            }

            .cravings-grid {
                grid-template-columns: repeat(3, 1fr);
            }

            .features-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .hero-card {
                grid-template-columns: 1fr;
                text-align: center;
                padding: 32px 24px;
            }

            .hero-desc {
                margin: 0 auto 28px;
            }

            .hero-title {
                font-size: 44px;
            }

            .hero-img {
                max-width: 320px;
                height: 260px;
            }

            .restaurant-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 16px;
            }

            .promo-banner {
                flex-direction: column;
                gap: 20px;
                text-align: center;
                padding: 32px 24px;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 0 16px;
            }

            .restaurant-grid {
                grid-template-columns: 1fr;
            }

            .cravings-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .restaurants-header {
                align-items: flex-start;
                gap: 10px;
            }

            .section-title {
                font-size: 30px;
            }

            .promo-title {
                font-size: 34px;
            }

            .promo-subtitle {
                font-size: 15px;
            }
        }
    </style>
</head>

<body>

    <%-- Shared navbar: login/signup or username/logout and cart count --%>
    <%@ include file="navbar.jsp" %>

    <main class="container">

        <!-- HERO SECTION -->
        <section class="hero-section">
            <div class="hero-card">
                <div>
                    <h1 class="hero-title">
                        Good Food Should Feel <span>Special</span>
                    </h1>

                    <p class="hero-desc">
                        Fresh ingredients. Bold flavours. Delivered straight
                        to your doorstep during late hours.
                    </p>

                    <a href="#restaurants" class="btn-primary">
                        Explore Today's Menu →
                    </a>
                </div>

                <div class="hero-img-container">
                    <img
                        src="<%= request.getContextPath() %>/midnight_cravings_images/Pasta%26Co/creamy-chicken-broccoli-fettuccine-alfredo.jpg"
                        alt="Featured pasta dish"
                        class="hero-img">

                    <div class="hero-tag">
                        Pasta Makes Everything Better!
                    </div>
                </div>
            </div>
        </section>

        <!-- PICK YOUR CRAVING -->
        <section>
            <h2 class="section-title">Pick Your Craving</h2>

            <div class="cravings-grid">

                <div class="craving-card active"
                     onclick="filterCategory('all', this)">
                    <div class="craving-img"
                         style="background:#FFC025; display:flex; align-items:center; justify-content:center; font-size:24px;">
                        ✨
                    </div>
                    <div class="craving-name">All Items</div>
                </div>

                <!-- Corrected Pizza image -->
                <div class="craving-card"
                     onclick="filterCategory('pizza', this)">
                    <img
                        src="<%= request.getContextPath() %>/midnight_cravings_images/Neonclub/margretapizza.webp"
                        class="craving-img"
                        alt="Pizza">
                    <div class="craving-name">Pizza</div>
                </div>

                <!-- Corrected Burger image -->
                <div class="craving-card"
                     onclick="filterCategory('burgers', this)">
                    <img
                        src="<%= request.getContextPath() %>/midnight_cravings_images/BurgerYard/ChickenBurger.png"
                        class="craving-img"
                        alt="Chicken Burger">
                    <div class="craving-name">Burgers</div>
                </div>

                <div class="craving-card"
                     onclick="filterCategory('biryani', this)">
                    <img
                        src="<%= request.getContextPath() %>/midnight_cravings_images/BiryaniHouse/chicken-biryani.webp"
                        class="craving-img"
                        alt="Biryani">
                    <div class="craving-name">Biryani</div>
                </div>

                <div class="craving-card"
                     onclick="filterCategory('south', this)">
                    <img
                        src="<%= request.getContextPath() %>/midnight_cravings_images/DosaJunction/masala-dosa.jpg"
                        class="craving-img"
                        alt="South Indian food">
                    <div class="craving-name">South Indian</div>
                </div>

                <div class="craving-card"
                     onclick="filterCategory('desserts', this)">
                    <img
                        src="<%= request.getContextPath() %>/midnight_cravings_images/Sweet%20Cravings/belgian-waffles.jpg"
                        class="craving-img"
                        alt="Desserts">
                    <div class="craving-name">Desserts</div>
                </div>

            </div>
        </section>

        <!-- FEATURED RESTAURANTS -->
        <section id="restaurants">
            <div class="restaurants-header">
                <h2 class="section-title">Featured Restaurants</h2>
                <a href="<%= request.getContextPath() %>/home"
                   class="view-all">View All →</a>
            </div>

            <div class="restaurant-grid" id="restaurantGrid">
                <%
                    List<Restaurant> restaurantList =
                        (List<Restaurant>) request.getAttribute("restaurants");

                    if (restaurantList != null && !restaurantList.isEmpty()) {
                        for (Restaurant r : restaurantList) {
                %>

                    <a href="<%= request.getContextPath() %>/menu?restaurantId=<%= r.getRestaurantId() %>"
                       class="restaurant-card"
                       data-category="<%= r.getCuisineType() == null ? "" : r.getCuisineType().toLowerCase() %>">

                        <div class="card-img-wrap">
                            <span class="badge">Popular</span>

                            <img
                                src="<%= request.getContextPath() %>/midnight_cravings_images/<%= r.getImagePath() %>"
                                alt="<%= r.getName() %>"
                                loading="lazy">
                        </div>

                        <div class="card-body">
                            <div class="card-header-row">
                                <h3 class="restaurant-name">
                                    <%= r.getName() %>
                                </h3>

                                <span class="rating">
                                    ★ <%= r.getRating() %>
                                </span>
                            </div>

                            <p class="cuisine-tags">
                                <%= r.getCuisineType() %>
                            </p>

                            <div class="card-footer-row">
                                <span class="delivery-time">
                                    Opens: <%= r.getOpeningTime() %>
                                </span>

                                <span class="action-btn">→</span>
                            </div>
                        </div>
                    </a>

                <%
                        }
                    } else {
                %>
                    <p class="empty-restaurants">
                        No restaurants available right now.
                    </p>
                <%
                    }
                %>
            </div>
        </section>

        <!-- PROMO BANNER -->
        <section class="promo-banner">
            <div>
                <h3 class="promo-title">
                    Cravings Can Wait...<br>
                    Good Food Can't! 💛
                </h3>

                <p class="promo-subtitle">
                    Order late night meals with zero extra delivery fee.
                </p>
            </div>

            <a href="#restaurants" class="btn-primary">
                Order Now →
            </a>
        </section>

        <!-- WHY CHOOSE US -->
        <section>
            <h2 class="section-title">Why Choose Us?</h2>

            <div class="features-grid">
                <div class="feature-item">
                    <div class="feature-icon">🌿</div>
                    <div>
                        <div class="feature-title">Fresh &amp; Quality</div>
                        <div class="feature-desc">
                            We use the freshest ingredients
                        </div>
                    </div>
                </div>

                <div class="feature-item">
                    <div class="feature-icon">🛡️</div>
                    <div>
                        <div class="feature-title">Safe &amp; Secure</div>
                        <div class="feature-desc">
                            Your data and payments are safe
                        </div>
                    </div>
                </div>

                <div class="feature-item">
                    <div class="feature-icon">🚀</div>
                    <div>
                        <div class="feature-title">Fast Delivery</div>
                        <div class="feature-desc">
                            Hot food delivered on time
                        </div>
                    </div>
                </div>

                <div class="feature-item">
                    <div class="feature-icon">😊</div>
                    <div>
                        <div class="feature-title">Happy Customers</div>
                        <div class="feature-desc">
                            Loved by thousands of foodies
                        </div>
                    </div>
                </div>
            </div>
        </section>

    </main>

    <!-- FOOTER -->
    <footer>
        — Good Food • Happy Mood —
    </footer>

    <!-- JAVASCRIPT -->
    <script>
        const contextPath = '<%= request.getContextPath() %>';

        const searchInput = document.getElementById('searchInput');
        const restaurantCards = document.querySelectorAll('.restaurant-card');
        const cartBtn = document.getElementById('cartBtn');

        // Navigate to the session-based cart.
        if (cartBtn) {
            cartBtn.addEventListener('click', function () {
                window.location.href = contextPath + '/cart';
            });
        }

        // Search restaurants by name or cuisine.
        if (searchInput) {
            searchInput.addEventListener('input', function () {
                const query = this.value.toLowerCase().trim();

                restaurantCards.forEach(function (card) {
                    const name = card.querySelector('.restaurant-name')
                        .textContent.toLowerCase();

                    const tags = card.querySelector('.cuisine-tags')
                        .textContent.toLowerCase();

                    const matches = name.includes(query) || tags.includes(query);

                    card.style.display = matches ? 'flex' : 'none';
                });
            });
        }

        // Filter restaurants by cuisine category.
        function filterCategory(category, element) {
            document.querySelectorAll('.craving-card').forEach(function (card) {
                card.classList.remove('active');
            });

            element.classList.add('active');

            if (searchInput) {
                searchInput.value = '';
            }

            restaurantCards.forEach(function (card) {
                const cuisine = (card.dataset.category || '').toLowerCase();

                let matches = category === 'all';

                if (category === 'pizza') {
                    matches = cuisine.includes('pizza');
                } else if (category === 'burgers') {
                    matches = cuisine.includes('burger');
                } else if (category === 'biryani') {
                    matches = cuisine.includes('biryani');
                } else if (category === 'south') {
                    matches = cuisine.includes('south')
                        || cuisine.includes('indian')
                        || cuisine.includes('dosa');
                } else if (category === 'desserts') {
                    matches = cuisine.includes('dessert')
                        || cuisine.includes('sweet')
                        || cuisine.includes('bakery');
                }

                card.style.display = matches ? 'flex' : 'none';
            });
        }
    </script>

</body>
</html>