<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Sign Up | Midnight Cravings</title>

<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
      rel="stylesheet">

<style>
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: 'Plus Jakarta Sans', sans-serif;
    background: #FFFDF7;
    color: #1E1E1E;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
}

.signup-container {
    width: 100%;
    max-width: 440px;
    background: #FFFFFF;
    padding: 36px;
    border-radius: 24px;
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
}

.brand {
    text-align: center;
    margin-bottom: 26px;
}

.brand-icon {
    width: 60px;
    height: 60px;
    background: #FFF2CC;
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 14px;
    font-size: 29px;
}

h1 {
    font-size: 26px;
    font-weight: 800;
}

h1 span {
    color: #D99A00;
}

.brand p,
.subtitle {
    color: #6C727F;
    font-size: 13px;
    margin-top: 8px;
}

h2 {
    font-size: 21px;
    margin-bottom: 7px;
}

.subtitle {
    margin-bottom: 22px;
}

.form-group {
    margin-bottom: 15px;
}

label {
    display: block;
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 7px;
}

input {
    width: 100%;
    padding: 12px 14px;
    border: 1px solid #E8E3DA;
    border-radius: 12px;
    outline: none;
    font-size: 14px;
    background: #FFFDF7;
}

input:focus {
    border-color: #FFC025;
    box-shadow: 0 0 0 3px rgba(255, 192, 37, 0.15);
}

.signup-btn {
    width: 100%;
    padding: 14px;
    background: #FFC025;
    color: #1E1E1E;
    border: none;
    border-radius: 12px;
    font-weight: 800;
    font-size: 14px;
    cursor: pointer;
    margin-top: 5px;
}

.signup-btn:hover {
    background: #F0B41F;
}

.message {
    padding: 11px 13px;
    border-radius: 10px;
    font-size: 13px;
    margin-bottom: 16px;
    background: #FFF0F0;
    color: #A12626;
}

.success {
    background: #FFF7DB;
    color: #765600;
}

.login-link {
    text-align: center;
    margin-top: 20px;
    font-size: 13px;
    color: #6C727F;
}

.login-link a {
    color: #8A6500;
    font-weight: 800;
    text-decoration: none;
}

@media (max-width: 480px) {
    .signup-container {
        padding: 27px 22px;
    }
}
</style>
</head>

<body>

<div class="signup-container">

    <div class="brand">
        <div class="brand-icon">🍽️</div>
        <h1>Midnight <span>Cravings</span></h1>
        <p>Your favourite food, just a few clicks away.</p>
    </div>

    <h2>Create your account</h2>
    <p class="subtitle">Join us and start ordering your favourites.</p>

    <% if ("1".equals(request.getParameter("error"))) { %>
        <div class="message">
            Please check your details and try again.
        </div>
    <% } %>

    <% if ("exists".equals(request.getParameter("error"))) { %>
        <div class="message">
            That username or email is already registered.
        </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/signup"
          method="post">

        <div class="form-group">
            <label for="username">Username</label>
            <input type="text"
                   id="username"
                   name="username"
                   maxlength="45"
                   autocomplete="username"
                   required>
        </div>

        <div class="form-group">
            <label for="email">Email</label>
            <input type="email"
                   id="email"
                   name="email"
                   maxlength="45"
                   autocomplete="email"
                   required>
        </div>

        <div class="form-group">
            <label for="password">Password</label>
            <input type="password"
                   id="password"
                   name="password"
                   minlength="8"
                   autocomplete="new-password"
                   required>
        </div>

        <div class="form-group">
            <label for="address">Delivery address</label>
            <input type="text"
                   id="address"
                   name="address"
                   maxlength="45"
                   autocomplete="street-address"
                   required>
        </div>

        <button type="submit" class="signup-btn">
            Create Account
        </button>

    </form>

   <p class="login-link">
    Already have an account?
    <a href="<%= request.getContextPath() %>/Login.jsp">
        Login
    </a>
</p>

</div>

</body>
</html>