<%@ page import="com.library.model.User" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Library Manager | Members</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root { --primary: #e67e22; --bg: #fdfcfb; }
        body { font-family: 'Segoe UI', sans-serif; background: var(--bg); margin: 0; display: flex; }
        .main { margin-left: 280px; padding: 40px; width: 100%; }
        .card { background: white; border-radius: 20px; padding: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 15px; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #eee; }
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; background: #e8f5e9; color: #2e7d32; }
    </style>
</head>
<body>
<div class="main">
    <div class="card">
        <h2>Member Profiles</h2>
        <table>
            <thead>
            <tr><th>ID</th><th>Username</th><th>Role</th><th>Status</th></tr>
            </thead>
            <tbody>
            <%
                List<User> users = (List<User>) request.getAttribute("userList");
                if(users != null) {
                    for(User u : users) {
            %>
            <tr>
                <td><%= u.getUserId() %></td>
                <td><%= u.getUsername() %></td>
                <td><%= (u.getRoleId() == 1 ? "Admin" : "Member") %></td>
                <td><span class="badge">Active</span></td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>