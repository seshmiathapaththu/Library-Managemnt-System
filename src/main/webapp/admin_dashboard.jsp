<%@ page import="com.library.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Library Manager | Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary: #e67e22;
            --primary-dark: #d35400;
            --sidebar-bg: #1a1a1a;
            --body-bg: #f4f7f6;
            --text-dark: #333;
            --text-light: #7f8c8d;
        }

        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; display: flex; background: var(--body-bg); color: var(--text-dark); }


        .sidebar { width: 260px; background: var(--sidebar-bg); color: white; height: 100vh; position: fixed; overflow-y: auto; padding: 20px 10px; z-index: 1000; }
        .logo { font-size: 22px; color: var(--primary); font-weight: bold; margin-bottom: 30px; padding-left: 15px; display: flex; align-items: center; }
        .logo i { margin-right: 10px; }

        .nav-section { font-size: 11px; text-transform: uppercase; color: #555; margin: 25px 0 10px 15px; letter-spacing: 1.5px; font-weight: bold; }
        .nav-item { padding: 12px 15px; margin: 4px 0; border-radius: 8px; cursor: pointer; transition: all 0.3s ease; display: flex; align-items: center; text-decoration: none; color: #adb5bd; font-size: 14px; }
        .nav-item i { margin-right: 12px; width: 20px; text-align: center; font-size: 16px; }
        .nav-item:hover { background: rgba(230, 126, 34, 0.1); color: var(--primary); }
        .nav-item.active { background: var(--primary); color: white; box-shadow: 0 4px 12px rgba(230, 126, 34, 0.3); }
        .nav-item.sign-out {
            color: var(--error-red) !important;
            margin-top: 50px;
        }
        .main-content { flex: 1; margin-left: 280px; padding: 40px; transition: all 0.3s; }
        .report-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .report-header h2 { margin: 0; font-weight: 600; color: #2c3e50; }

        #tab-container { background: white; border-radius: 12px; padding: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); min-height: 60vh; }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; background: white; }
        table th { background-color: #f8f9fa; color: var(--text-light); font-weight: 600; text-align: left; padding: 15px; border-bottom: 2px solid #edf2f7; text-transform: uppercase; font-size: 12px; letter-spacing: 0.5px; }
        table td { padding: 15px; border-bottom: 1px solid #edf2f7; color: #4a5568; font-size: 14px; }
        table tr:hover { background-color: #fffaf5; }

        .badge { padding: 5px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-danger { background: #fee2e2; color: #dc2626; }
        .badge-success { background: #dcfce7; color: #16a34a; }

        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-thumb { background: #444; border-radius: 10px; }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="logo"> Library Manager</div>

    <div class="nav-section">Core Management</div>
    <a href="javascript:void(0)" id="default-tab" class="nav-item" onclick="loadTab('ManageUsersServlet', this)">
        <i class="fas fa-users-cog"></i> Users
    </a>
    <a href="javascript:void(0)" class="nav-item" onclick="loadTab('ManageBooksServlet', this)">
        <i class="fas fa-book"></i> Books
    </a>

    <div class="nav-section">Finance (LKR)</div>
    <a href="javascript:void(0)" class="nav-item" onclick="loadTab('ReportServlet?type=payments', this)">
        <i class="fas fa-file-invoice-dollar"></i> Transactions
    </a>

    <div class="nav-section">Reports & Tracking</div>
    <a href="javascript:void(0)" class="nav-item" onclick="loadTab('ReportServlet?type=overdue', this)">
        <i class="fas fa-clock"></i> Overdue Books
    </a>
    <a href="javascript:void(0)" class="nav-item" onclick="loadTab('ReportServlet?type=history', this)">
        <i class="fas fa-history"></i> Issue History
    </a>

    <div class="nav-section">Safety</div>
    <a href="javascript:void(0)" class="nav-item" onclick="loadTab('ReportServlet?type=logs', this)">
        <i class="fas fa-shield-alt"></i> Access Logs
    </a>

    <a href="LogoutServlet" class="nav-item sign-out-btn" style="color: red;">
        <i class="fas fa-sign-out-alt"></i> Sign Out
    </a>

</div>

<div class="main-content">
    <div class="report-header">
        <div>
            <p style="color: var(--text-light); margin: 0; font-size: 14px;">Administrator Access,</p>
            <h2><%= currentUser.getUsername() %></h2>
        </div>
        <div id="current-date" style="font-size: 14px; color: var(--text-light)"></div>
    </div>

    <div id="tab-container">
    </div>
</div>

<script>
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


    document.getElementById('current-date').innerText = new Date().toLocaleDateString('en-GB', {
        weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
    });

    function loadTab(servletUrl, element) {
        document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));

        if (element) {
            element.classList.add('active');
        } else {
            const usersTab = document.getElementById('default-tab');
            if (usersTab) usersTab.classList.add('active');
        }

        document.getElementById('tab-container').innerHTML =
            "<div style='text-align:center; padding:100px;'><i class='fas fa-circle-notch fa-spin fa-3x' style='color: var(--primary)'></i><p style='margin-top:15px; color:#666;'>Fetching records...</p></div>";

        fetch(servletUrl)
            .then(response => {
                if (!response.ok) throw new Error('Data could not be retrieved.');
                return response.text();
            })
            .then(html => {

                document.getElementById('tab-container').innerHTML = html;
            })
            .catch(err => {
                document.getElementById('tab-container').innerHTML =
                    "<div style='text-align:center; color:#e74c3c; padding:100px;'>" +
                    "<i class='fas fa-exclamation-circle fa-3x'></i>" +
                    "<p style='margin-top:15px; font-weight:bold;'>Error: " + err.message + "</p></div>";
            });
    }

    window.onload = function() {
        loadTab('ManageUsersServlet', null);
    };
</script>
</body>
</html>