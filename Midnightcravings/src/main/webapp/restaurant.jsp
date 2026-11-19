<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.tap.Model.Restaurant"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restaurants | Midnight Cravings</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Caveat:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

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

        /* NAVBAR (Styles kept so the included navbar renders properly) */
        .navbar {
            background-color: var(--bg-cream);
            position: sticky;
            top: 0;
            z-index: 100;
            border-bottom: 1px solid var(--border-light);
            padding: 16px 0;
        }

        .nav-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-icon {
            background: var(--primary-yellow);
            width: 42px;
            height: 42px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .brand-title {
            font-weight: 800;
            font-size: 22px;
            letter-spacing: -0.5px;
        }

        .brand-subtitle {
            font-family: var(--font-hand);
            font-size: 16px;
            color: var(--accent-orange);
            display: block;
            margin-top: -6px;
        }

        .nav-links {
            display: flex;
            gap: 32px;
            list-style: none;
            font-weight: 600;
            font-size: 15px;
        }

        .nav-links a:hover,
        .nav-links a.active {
            color: var(--accent-orange);
        }

        /* PAGE HEADER */
        .page-header {
            text-align: center;
            margin: 40px 0 20px;
        }

        .page-title {
            font-family: var(--font-hand);
            font-size: 48px;
            color: var(--text-dark);
        }

        .page-subtitle {
            color: var(--text-muted);
            font-size: 16px;
            margin-top: -8px;
        }

        /* RESTAURANT GRID */
        .restaurant-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 28px;
            margin: 32px 0 60px;
        }

        .restaurant-card {
            background: var(--bg-card);
            border-radius: 24px;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            flex-direction: column;
        }

        .restaurant-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-md);
        }

        .card-img-wrapper {
            position: relative;
            width: 100%;
            height: 180px;
        }

        .card-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .rating-badge {
            position: absolute;
            bottom: 12px;
            right: 12px;
            background: #EAF7ED;
            color: #2E7D32;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 13px;
            box-shadow: var(--shadow-sm);
        }

        .card-content {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex: 1;
            justify-content: space-between;
        }

        .res-name {
            font-size: 20px;
            font-weight: 800;
            margin-bottom: 4px;
        }

        .res-cuisine {
            font-size: 14px;
            color: var(--text-muted);
            font-weight: 500;
            margin-bottom: 12px;
        }

        .res-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 12px;
            border-top: 1px solid var(--border-light);
            font-size: 13px;
            color: var(--text-muted);
        }

        .view-menu-btn {
            background: var(--primary-yellow);
            color: var(--text-dark);
            font-weight: 700;
            padding: 8px 16px;
            border-radius: 12px;
            font-size: 13px;
            transition: background 0.2s;
        }

        .view-menu-btn:hover {
            background: var(--accent-orange);
            color: white;
        }

        /* FOOTER (Styles kept so included footer renders properly) */
        footer {
            background: var(--primary-yellow);
            padding: 24px 0;
            text-align: center;
            font-family: var(--font-hand);
            font-size: 24px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <!-- SHARED NAVBAR INCLUDED HERE -->
    <jsp:include page="navbar.jsp" />

    <!-- MAIN CONTENT -->
    <main class="container">

        <div class="page-header">
            <h1 class="page-title">Explore Restaurants</h1>
            <p class="page-subtitle">Pick a restaurant to view its delicious menu</p>
        </div>

        <div class="restaurant-grid">
            <%
                List<Restaurant> restaurantList = (List<Restaurant>) request.getAttribute("restaurantList");

                if (restaurantList != null && !restaurantList.isEmpty()) {
                    for (Restaurant r : restaurantList) {
            %>

            <a href="menu?restaurantId=<%= r.getRestaurantId() %>" class="restaurant-card">
                <div class="card-img-wrapper">
                    <img src="midnight_cravings_images/<%= r.getImagePath() %>" 
                         alt="<%= r.getName() %>" 
                         class="card-img"
                         onerror="this.src='https://via.placeholder.com/320x180?text=Restaurant';">
                    <span class="rating-badge">★ <%= r.getRating() %></span>
                </div>

                <div class="card-content">
                    <div>
                        <h2 class="res-name"><%= r.getName() %></h2>
                        <p class="res-cuisine"><%= r.getCuisineType() %></p>
                    </div>

                    <div class="res-footer">
                        <span>🕒 <%= r.getOpeningTime() %></span>
                        <span class="view-menu-btn">View Menu →</span>
                    </div>
                </div>
            </a>

            <%
                    }
                } else {
            %>
                <p style="grid-column: 1 / -1; text-align: center; color: var(--text-muted); font-size: 18px; margin: 40px 0;">
                    No restaurants available at the moment.
                </p>
            <%
                }
            %>
        </div>

    </main>

    <!-- SHARED FOOTER INCLUDED HERE -->
    <jsp:include page="footer.jsp" />

</body>
</html>