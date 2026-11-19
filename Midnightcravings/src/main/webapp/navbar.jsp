
<%@ page import="java.util.Map" %>
<%@ page import="com.tap.Model.Cart" %>
<%@ page import="com.tap.Model.CartItem" %>

<%
    String loggedInUsername = (String) session.getAttribute("username");
    boolean loggedIn = loggedInUsername != null;

    int totalCartCount = 0;
    Cart cart = (Cart) session.getAttribute("cart");

    if (cart != null && cart.getItems() != null) {
        for (CartItem item : cart.getItems().values()) {
            totalCartCount += item.getQuantity();
        }
    }

    String contextPath = request.getContextPath();
%>

<style>
    .navbar {
        width: 100%;
        background: #FFFDF7;
        border-bottom: 1px solid #F0E8D6;
        position: sticky;
        top: 0;
        z-index: 1000;
    }

    .nav-wrapper {
        max-width: 1200px;
        margin: 0 auto;
        padding: 14px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 22px;
    }

    .brand-logo {
        display: flex;
        align-items: center;
        gap: 10px;
        text-decoration: none;
        color: #252525;
        flex-shrink: 0;
    }

    .logo-icon {
        width: 43px;
        height: 43px;
        border-radius: 50%;
        background: #FFC025;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .logo-icon svg {
        width: 29px;
        height: 29px;
        display: block;
    }

    .brand-title {
        display: block;
        font-family: "Plus Jakarta Sans", sans-serif;
        font-size: 20px;
        font-weight: 800;
        line-height: 1.2;
    }

    .brand-subtitle {
        display: block;
        margin-top: 3px;
        color: #8A6A13;
        font-size: 11px;
        font-weight: 600;
    }

    .nav-links {
        display: flex;
        align-items: center;
        gap: 25px;
    }

    .nav-links a,
    .orders-link {
        color: #444444;
        text-decoration: none;
        font-size: 14px;
        font-weight: 600;
        transition: color 0.2s;
        white-space: nowrap;
    }

    .nav-links a:hover,
    .orders-link:hover {
        color: #B88600;
    }

    .nav-actions {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .cart-btn {
        position: relative;
        width: 43px;
        height: 43px;
        border: none;
        border-radius: 14px;
        background: #FFF3C4;
        color: #252525;
        font-size: 21px;
        cursor: pointer;
        flex-shrink: 0;
    }

    .cart-btn:hover {
        background: #FFE69A;
    }

    .cart-badge {
        position: absolute;
        top: -6px;
        right: -6px;
        min-width: 19px;
        height: 19px;
        padding: 0 4px;
        border-radius: 20px;
        background: #FFC025;
        color: #252525;
        font-size: 11px;
        font-weight: 800;
        display: flex;
        align-items: center;
        justify-content: center;
        box-sizing: border-box;
    }

    .account-link,
    .logout-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 10px 15px;
        border-radius: 10px;
        font-family: inherit;
        font-size: 13px;
        font-weight: 700;
        text-decoration: none;
        white-space: nowrap;
        cursor: pointer;
    }

    .account-link {
        color: #333333;
        border: 1px solid #E8DDBF;
        background: transparent;
    }

    .account-link:hover {
        background: #FFF3C4;
    }

    .account-link.signup-link {
        background: #FFC025;
        border-color: #FFC025;
        color: #252525;
    }

    .account-link.signup-link:hover {
        background: #F4B400;
    }

    .welcome-user {
        color: #444444;
        font-size: 13px;
        font-weight: 700;
        white-space: nowrap;
    }

    .navbar .logout-btn {
        border: none;
        background: #FFC025;
        color: #252525;
    }

    .navbar .logout-btn:hover {
        background: #F4B400;
    }

    /* Logout confirmation popup */
    .mc-logout-modal {
        display: none;
        position: fixed;
        inset: 0;
        z-index: 10000;
        padding: 20px;
        background: rgba(41, 37, 28, 0.58);
        align-items: center;
        justify-content: center;
    }

    .mc-logout-modal.show {
        display: flex;
    }

    .mc-logout-content {
        width: 100%;
        max-width: 400px;
        padding: 32px 26px;
        background: #FFFDF7;
        border: 1px solid #F0E8D5;
        border-radius: 20px;
        text-align: center;
        box-shadow: 0 20px 60px rgba(41, 37, 28, 0.2);
        animation: mcPopupAppear 0.2s ease-out;
    }

    .mc-logout-icon {
        width: 60px;
        height: 60px;
        margin: 0 auto 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #FFF3C4;
        color: #29251C;
        border-radius: 50%;
        font-size: 29px;
        font-weight: bold;
    }

    .mc-logout-content h2 {
        margin: 0 0 12px;
        color: #29251C;
        font-size: 23px;
    }

    .mc-logout-content p {
        margin: 0 0 26px;
        color: #6B6559;
        font-size: 14px;
        line-height: 1.7;
    }

    .mc-logout-actions {
        display: flex;
        gap: 12px;
    }

    .mc-cancel-btn,
    .mc-confirm-btn {
        flex: 1;
        padding: 12px 14px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: bold;
        cursor: pointer;
        transition: background 0.2s ease;
    }

    .mc-cancel-btn {
        background: transparent;
        color: #29251C;
        border: 1px solid #E8DDBF;
    }

    .mc-cancel-btn:hover {
        background: #FFF3C4;
    }

    .mc-confirm-btn {
        background: #FFC025;
        color: #29251C;
        border: 1px solid #FFC025;
    }

    .mc-confirm-btn:hover {
        background: #F2B313;
    }

    @keyframes mcPopupAppear {
        from {
            opacity: 0;
            transform: translateY(8px) scale(0.97);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }

    @media (max-width: 1000px) {
        .nav-wrapper {
            flex-wrap: wrap;
            padding: 12px 16px;
        }

        .nav-links {
            order: 3;
            width: 100%;
            justify-content: center;
            gap: 22px;
        }

        .nav-actions {
            margin-left: auto;
        }
    }

    @media (max-width: 600px) {
        .brand-title {
            font-size: 16px;
        }

        .brand-subtitle {
            font-size: 10px;
        }

        .logo-icon {
            width: 38px;
            height: 38px;
        }

        .logo-icon svg {
            width: 26px;
            height: 26px;
        }

        .nav-wrapper {
            gap: 12px;
        }

        .nav-links {
            gap: 15px;
        }

        .nav-links a,
        .orders-link {
            font-size: 12px;
        }

        .welcome-user {
            display: none;
        }

        .account-link,
        .logout-btn {
            padding: 9px 10px;
            font-size: 12px;
        }

        .nav-actions {
            gap: 7px;
        }

        .mc-logout-content {
            padding: 26px 18px;
        }

        .mc-logout-actions {
            flex-direction: column;
        }
    }
</style>

<nav class="navbar">
    <div class="nav-wrapper">

        <a class="brand-logo"
           href="<%= contextPath %>/home">

            <span class="logo-icon">
                <svg viewBox="0 0 48 48"
                     xmlns="http://www.w3.org/2000/svg"
                     aria-hidden="true">

                    <g fill="none"
                       stroke="#29251C"
                       stroke-width="3"
                       stroke-linecap="round"
                       stroke-linejoin="round">

                        <path d="M13 7 V18"/>
                        <path d="M8 7 V14 A5 5 0 0 0 18 14 V7"/>
                        <path d="M13 19 V41"/>

                        <ellipse cx="32" cy="13" rx="5" ry="7"/>
                        <path d="M32 20 V41"/>

                    </g>
                </svg>
            </span>

            <span>
                <span class="brand-title">Midnight Cravings</span>
                <span class="brand-subtitle">Good food, anytime</span>
            </span>
        </a>

        <div class="nav-links">
            <a href="<%= contextPath %>/home">Home</a>
            <a href="<%= contextPath %>/restaurants">Restaurants</a>
            <a href="<%= contextPath %>/cart">Cart</a>
        </div>

        <div class="nav-actions">

            <button class="cart-btn"
                    type="button"
                    aria-label="Shopping cart"
                    onclick="window.location.href='<%= contextPath %>/cart'">

                &#128722;

                <span class="cart-badge" id="cartCount">
                    <%= totalCartCount %>
                </span>
            </button>

            <a class="orders-link"
               href="<%= contextPath %>/order-history.jsp">
                My Orders
            </a>

            <% if (loggedIn) { %>

                <span class="welcome-user">
                    Hi, <%= loggedInUsername %>
                </span>

                <form id="mcNavbarLogoutForm"
                      action="<%= contextPath %>/logout"
                      method="post"
                      style="margin: 0;">

                    <button type="button"
                            class="logout-btn"
                            onclick="openMcLogoutModal()">
                        Logout
                    </button>
                </form>

            <% } else { %>

                <a class="account-link"
                   href="<%= contextPath %>/Login.jsp">
                    Login
                </a>

                <a class="account-link signup-link"
                   href="<%= contextPath %>/Signup.jsp">
                    Sign Up
                </a>

            <% } %>

        </div>
    </div>
</nav>

<% if (loggedIn) { %>

    <!-- Custom popup: rendered only for logged-in users -->
    <div id="mcNavbarLogoutModal"
         class="mc-logout-modal"
         role="dialog"
         aria-modal="true"
         aria-labelledby="mcLogoutTitle"
         aria-describedby="mcLogoutMessage">

        <div class="mc-logout-content">

            <div class="mc-logout-icon" aria-hidden="true">
    &#10003;
</div>

            <h2 id="mcLogoutTitle">Leaving so soon?</h2>

            <p id="mcLogoutMessage">
                Are you sure you want to logout from Midnight Cravings?
            </p>

            <div class="mc-logout-actions">

                <button type="button"
                        class="mc-cancel-btn"
                        onclick="closeMcLogoutModal()">
                    Cancel
                </button>

                <button type="button"
                        class="mc-confirm-btn"
                        id="mcConfirmLogoutButton"
                        onclick="confirmMcLogout()">
                    Yes, Logout
                </button>

            </div>
        </div>
    </div>

    <script>
        (function () {
            const modal = document.getElementById("mcNavbarLogoutModal");
            const confirmButton =
                document.getElementById("mcConfirmLogoutButton");

            window.openMcLogoutModal = function () {
                modal.classList.add("show");
                confirmButton.focus();
            };

            window.closeMcLogoutModal = function () {
                modal.classList.remove("show");
            };

            window.confirmMcLogout = function () {
                document.getElementById("mcNavbarLogoutForm").submit();
            };

            modal.addEventListener("click", function (event) {
                if (event.target === modal) {
                    window.closeMcLogoutModal();
                }
            });

            document.addEventListener("keydown", function (event) {
                if (event.key === "Escape" &&
                    modal.classList.contains("show")) {
                    window.closeMcLogoutModal();
                }
            });
        })();
    </script>

<% } %>
