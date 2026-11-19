
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Midnight Cravings</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            background: #FFFDF7;
            font-family: "Plus Jakarta Sans", sans-serif;
            color: #252525;
            display: flex;
            flex-direction: column;
        }

        .page-content {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 35px 18px;
        }

        .login-card {
            width: 100%;
            max-width: 430px;
            padding: 38px;
            background: #FFFFFF;
            border: 1px solid #F0E8D6;
            border-radius: 22px;
            box-shadow: 0 12px 35px rgba(80, 60, 10, 0.07);
        }

        .welcome-icon {
            width: 58px;
            height: 58px;
            margin-bottom: 22px;
            border-radius: 18px;
            background: #FFF3C4;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
        }

        h1 {
            margin-bottom: 10px;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.8px;
        }

        .description {
            margin-bottom: 27px;
            color: #777777;
            font-size: 14px;
            line-height: 1.7;
        }

        .message {
            padding: 12px 14px;
            margin-bottom: 18px;
            border-radius: 10px;
            font-size: 13px;
            line-height: 1.5;
        }

        .error-message {
            background: #FFF0EE;
            color: #B42318;
        }

        .success-message {
            background: #FFF7DB;
            color: #765600;
        }

        .form-group {
            margin-bottom: 19px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-size: 13px;
            font-weight: 700;
        }

        .login-card input {
            width: 100%;
            padding: 13px 14px;
            border: 1px solid #E5E0D5;
            border-radius: 11px;
            background: #FFFDF9;
            color: #252525;
            font-family: inherit;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .login-card input:focus {
            border-color: #E5AA00;
            box-shadow: 0 0 0 3px rgba(255, 192, 37, 0.18);
        }

        .login-btn {
            width: 100%;
            padding: 14px;
            margin-top: 5px;
            border: none;
            border-radius: 11px;
            background: #FFC025;
            color: #252525;
            font-family: inherit;
            font-size: 14px;
            font-weight: 800;
            cursor: pointer;
            transition: background 0.2s, transform 0.2s;
        }

        .login-btn:hover {
            background: #F4B400;
            transform: translateY(-1px);
        }

        .signup-text {
            margin-top: 23px;
            text-align: center;
            color: #777777;
            font-size: 13px;
        }

        .signup-text a {
            color: #8A6500;
            font-weight: 800;
            text-decoration: none;
        }

        .signup-text a:hover {
            text-decoration: underline;
        }

        .back-link {
            display: block;
            margin-top: 24px;
            color: #777777;
            text-align: center;
            font-size: 13px;
            text-decoration: none;
        }

        .back-link:hover {
            color: #8A6500;
        }

        @media (max-width: 480px) {
            .login-card {
                padding: 27px 22px;
            }

            h1 {
                font-size: 25px;
            }
        }
    </style>
</head>

<body>

    <%@ include file="navbar.jsp" %>

    <main class="page-content">
        <section class="login-card">

            <div class="welcome-icon">👋</div>

            <h1>Welcome back!</h1>

            <p class="description">
                Log in to your account and get ready to enjoy your favourite food.
            </p>

            <% String error = request.getParameter("error"); %>
            <% String message = request.getParameter("message"); %>

            <% if ("1".equals(error)) { %>
                <div class="message error-message">
                    Invalid username/email or password. Please try again.
                </div>
            <% } %>

            <% if ("signupSuccess".equals(message)) { %>
                <div class="message success-message">
                    Account created successfully! Please log in.
                </div>
            <% } %>

            <% if ("loggedOut".equals(message)) { %>
                <div class="message success-message">
                    You have been logged out successfully.
                </div>
            <% } %>

            <% if ("1".equals(request.getParameter("loginRequired"))) { %>
                <div class="message success-message">
                    Please log in to continue.
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/login" method="post">

                <div class="form-group">
                    <label for="username">Username or email</label>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        placeholder="Enter your username or email"
                        autocomplete="username"
                        required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        placeholder="Enter your password"
                        autocomplete="current-password"
                        required>
                </div>

                <button type="submit" class="login-btn">
                    Login
                </button>

            </form>

            <p class="signup-text">
                Don't have an account?
               <a href="<%= request.getContextPath() %>/Signup.jsp">Sign Up</a>
            </p>

            <a class="back-link"
               href="<%= request.getContextPath() %>/home">
                ← Back to restaurants
            </a>

        </section>
    </main>

</body>
</html>
