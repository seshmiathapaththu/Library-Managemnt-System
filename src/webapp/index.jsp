<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Library Manager | Login</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        * {
            box-sizing: border-box;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        body {
            margin: 0;
            height: 100vh;
            background: linear-gradient(120deg, #1c1c1c 50%, #f4f6f8 50%);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-container {
            width: 380px;
            background: #ffffff;
            border-radius: 12px;
            padding: 35px 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }

        .alert-box {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13.5px;
            display: flex;
            align-items: center;
            border: 1px solid;
            animation: fadeIn 0.4s ease;
        }

        .alert-error {
            background-color: #fff5f5;
            color: #c53030;
            border-color: #feb2b2;
        }

        .alert-box i {
            margin-right: 10px;
            font-size: 16px;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .brand {
            text-align: center;
            margin-bottom: 10px;
            color: #f08a24;
            font-weight: 700;
            font-size: 18px;
        }

        .login-header {
            text-align: center;
            margin-bottom: 25px;
        }

        .login-header h2 {
            margin: 0;
            color: #1c1c1c;
            font-size: 24px;
            font-weight: 700;
        }

        .login-header p {
            margin-top: 6px;
            color: #777;
            font-size: 14px;
        }

        label {
            font-size: 14px;
            font-weight: 600;
            color: #333;
            margin-bottom: 6px;
            display: block;
        }

        input {
            width: 100%;
            padding: 11px 12px;
            border-radius: 8px;
            border: 1px solid #ddd;
            margin-bottom: 18px;
            font-size: 14px;
        }

        input:focus {
            outline: none;
            border-color: #f08a24;
            box-shadow: 0 0 0 2px rgba(240,138,36,0.15);
        }

        button {
            width: 100%;
            padding: 12px;
            background: #f08a24;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s ease;
            margin-top: 5px;
        }

        button:hover {
            background: #d97412;
        }

        .footer-text {
            text-align: center;
            margin-top: 18px;
            font-size: 13px;
            color: #888;
        }
    </style>
</head>
<body>

<div class="login-container">

    <div class="brand"><i class="fas fa-book-reader"></i> Library Manager</div>

    <div class="login-header">
        <h2>Welcome Back</h2>
        <p>Sign in to continue</p>
    </div>

    <%
        String error = request.getParameter("error");
        if (error != null) {
    %>
    <div class="alert-box alert-error">
        <i class="fas fa-exclamation-circle"></i>
        <span>
                <%
                    if(error.equals("invalid")) out.print("Incorrect username or password.");
                    else if(error.equals("deactivated")) out.print("Account deactivated. Contact Admin.");
                    else if(error.equals("unknown_role")) out.print("Unassigned role. Access denied.");
                    else out.print("An unexpected error occurred.");
                %>
            </span>
    </div>
    <% } %>

    <form action="<%= request.getContextPath() %>/LoginServlet" method="post">

        <label for="username">Username</label>
        <input type="text" id="username" name="username" placeholder="Enter username" required>

        <label for="password">Password</label>
        <input type="password" id="password" name="password" placeholder="Enter password" required>

        <button type="submit">Login</button>

    </form>

    <div class="footer-text">
        &copy; 2025 Library Management System
    </div>

</div>

</body>
</html>