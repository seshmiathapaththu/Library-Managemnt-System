<%@ page import="com.library.model.User" %>
<%@ page import="java.util.List" %>

<style>
    .modal { display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); }
    .modal-content { background: white; margin: 10% auto; padding: 30px; border-radius: 15px; width: 400px; box-shadow: 0 5px 25px rgba(0,0,0,0.5); position: relative; animation: modalFadeIn 0.3s ease; }
    @keyframes modalFadeIn { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 8px; color: #333; font-weight: bold; }
    .form-group input, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; box-sizing: border-box; background-color: #f8faff; }

    .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
    .status-active { background: #e8f5e9; color: #27ae60; }
    .status-inactive { background: #ffebee; color: #e74c3c; }

    .search-wrapper { margin-bottom: 25px; }
    .search-box-container { display: flex; border: 1px solid #ddd; border-radius: 25px; background: white; overflow: hidden; width: 350px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .search-box-container input { border: none; padding: 10px 20px; flex: 1; outline: none; font-size: 14px; }
    .search-box-container button { border: none; background: #f39c12; color: white; padding: 0 20px; cursor: pointer; transition: 0.3s; }

    .btn-submit { background:#27ae60; color:white; border:none; padding:12px; border-radius:8px; flex:1; cursor:pointer; font-weight:bold; }
    .btn-cancel { background:#888; color:white; border:none; padding:12px; border-radius:8px; flex:1; cursor:pointer; }
</style>

<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
    <h2 style="margin:0; font-weight: bold;">Member Management</h2>
    <button type="button" onclick="document.getElementById('addModal').style.display='block'"
            style="background: #e67e22; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: bold;">
        + Add New Member
    </button>
</div>

<div class="search-wrapper">
    <div class="search-box-container">
        <input type="text" id="memberSearch" placeholder="Search by name..." onkeydown="if(event.key==='Enter') performSearch()">
        <button type="button" onclick="performSearch()">
            <i class="fas fa-search"></i>
        </button>
    </div>
</div>

<div id="addModal" class="modal">
    <div class="modal-content">
        <h2 style="margin-top:0; font-weight: bold;">Add New Member</h2>
        <form action="UserActionServlet" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label for="name">Full Name</label>
                <input type="text" id="name" name="name" placeholder="Full Name" required>
            </div>
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" placeholder="Username" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Email Address" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Password" required>
            </div>
            <div class="form-group">
                <label for="roleId">Role</label>
                <select id="roleId" name="roleId">
                    <option value="1">Admin</option>
                    <option value="2">Librarian</option>
                    <option value="3">Member</option>
                </select>
            </div>
            <div style="display: flex; gap: 15px; margin-top: 25px;">
                <button type="submit" class="btn-submit">Add Member</button>
                <button type="button" onclick="document.getElementById('addModal').style.display='none'" class="btn-cancel">Cancel</button>
            </div>
        </form>
    </div>
</div>

<div id="passwordModal" class="modal">
    <div class="modal-content">
        <h2 style="margin-top:0; font-weight: bold;">Reset Password</h2>
        <p id="passwordTargetName" style="color: #666; margin-bottom: 20px; font-size: 14px;"></p>
        <form action="UserActionServlet" method="POST">
            <input type="hidden" name="action" value="changePassword">
            <input type="hidden" name="userId" id="passwordUserId">
            <div class="form-group">
                <label for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" placeholder="Enter new password" required>
            </div>
            <div style="display: flex; gap: 15px; margin-top: 25px;">
                <button type="submit" class="btn-submit">Update Password</button>
                <button type="button" onclick="document.getElementById('passwordModal').style.display='none'" class="btn-cancel">Cancel</button>
            </div>
        </form>
    </div>
</div>

<table id="memberDataTable" style="width:100%; border-collapse: collapse; background: white;">
    <thead>
    <tr style="text-align:left; color: #333; border-bottom: 2px solid #eee;">
        <th style="padding:15px;">Name</th>
        <th>Username</th>
        <th>Email</th>
        <th>Status</th>
        <th style="text-align: center;">Actions</th>
    </tr>
    </thead>
    <tbody>
    <%

        @SuppressWarnings("unchecked")
        List<User> usersList = (List<User>) request.getAttribute("userList");
        if(usersList != null && !usersList.isEmpty()) {
            for(User u : usersList) {
                boolean isActive = u.getStatus().equalsIgnoreCase("Active");
    %>
    <tr class="user-row" style="border-bottom: 1px solid #eee;">
        <td class="user-name" style="padding:15px; font-weight: 500;"><%= u.getName() %></td>
        <td><%= u.getUsername() %></td>
        <td><%= u.getEmail() %></td>
        <td><span class="status-badge <%= isActive ? "status-active" : "status-inactive" %>"><%= u.getStatus() %></span></td>
        <td style="text-align: center; display: flex; justify-content: center; align-items: center; gap: 15px; padding: 15px 0;">
            <button type="button"
                    onclick="openPasswordModal('<%= u.getUserId() %>', '<%= u.getName() %>')"
                    style="background:none; border:none; cursor:pointer; color:#3498db; font-size:18px;"
                    title="Reset Password">
                <i class="fas fa-key"></i>
            </button>

            <form action="UserActionServlet" method="POST" style="display:inline; margin:0;">
                <input type="hidden" name="action" value="toggleStatus">
                <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                <input type="hidden" name="currentStatus" value="<%= u.getStatus() %>">
                <button type="submit" style="background:none; border:none; cursor:pointer; padding:0;">
                    <i class="fas <%= isActive ? "fa-toggle-on" : "fa-toggle-off" %>"
                       style="font-size: 24px; color: <%= isActive ? "#27ae60" : "#bdc3c7" %>;"></i>
                </button>
            </form>

            <form action="UserActionServlet" method="POST" style="display:inline; margin:0;" onsubmit="return confirm('Delete user?')">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                <button type="submit" style="background:none; border:none; color:#e74c3c; cursor:pointer; font-size:18px;">
                    <i class="fas fa-trash"></i>
                </button>
            </form>
        </td>
    </tr>
    <% } } %>
    </tbody>
</table>

<script>
    function performSearch() {
        const queryInput = document.getElementById('memberSearch');
        if (queryInput) {
            const query = queryInput.value;
            loadTab('ManageUsersServlet?searchQuery=' + encodeURIComponent(query), null);
        }
    }

    function openPasswordModal(userId, userName) {
        const modal = document.getElementById('passwordModal');
        const idField = document.getElementById('passwordUserId');
        const nameField = document.getElementById('passwordTargetName');

        if (modal && idField && nameField) {
            idField.value = userId;
            nameField.innerText = "Resetting password for: " + userName;
            modal.style.display = 'block';
        }
    }

    window.onclick = function(event) {
        const addModal = document.getElementById('addModal');
        const passModal = document.getElementById('passwordModal');
        if (event.target === addModal) addModal.style.display = "none";
        if (event.target === passModal) passModal.style.display = "none";
    };
</script>