<%@ page import="com.library.model.User, com.library.model.Book, com.library.model.Transaction, java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>User Dashboard | Library Manager</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    <style>
        :root { --primary-orange: #e67e22; --sidebar-bg: #1a1a1a; --body-bg: #f8f9fa; }
        body { font-family: 'Segoe UI', sans-serif; margin: 0; display: flex; background: var(--body-bg); }
        .sidebar { width: 260px; background: var(--sidebar-bg); color: white; height: 100vh; position: fixed; padding: 20px; box-sizing: border-box; }
        .logo { font-size: 24px; color: var(--primary-orange); font-weight: bold; margin-bottom: 40px; }
        .nav-item { padding: 12px; margin: 8px 0; border-radius: 8px; cursor: pointer; display: block; text-decoration: none; color: #ccc; transition: 0.3s; }
        .nav-item:hover, .nav-item.active { background: var(--primary-orange); color: white; }
        .nav-item i { margin-right: 12px; width: 20px; text-align: center; }
        .main-content { flex: 1; margin-left: 260px; padding: 40px; }
        #tab-container { background: white; border-radius: 15px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); min-height: 400px; transition: opacity 0.3s; }
        .book-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .book-table th { text-align: left; border-bottom: 2px solid #eee; padding: 12px; color: #7f8c8d; }
        .book-table td { padding: 12px; border-bottom: 1px solid #f1f1f1; }
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; }
        .badge-success { background: #e8f5e9; color: #27ae60; }
        .badge-warning { background: #fff3e0; color: #ef6c00; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); }
        .modal-content { background: white; margin: 10% auto; padding: 30px; border-radius: 15px; width: 400px; box-shadow: 0 5px 20px rgba(0,0,0,0.2); }
        .payment-btn { background: #27ae60; color: white; border: none; padding: 8px 12px; border-radius: 5px; cursor: pointer; font-weight: bold; margin-top: 5px; display: block;}
        .close-modal { float: right; cursor: pointer; font-size: 20px; color: #7f8c8d; }
        .profile-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-top: 20px; }
        .info-card { padding: 20px; border: 1px solid #eee; border-radius: 10px; background: #fafafa; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; margin-top: 5px; }
        .btn-primary { background: var(--primary-orange); color: white; border: none; padding: 12px; border-radius: 5px; font-weight: bold; cursor: pointer; width: 100%; margin-top: 15px; }
        .loading-state { opacity: 0.5; pointer-events: none; }
    </style>
</head>
<body onload="initializeDashboard()">

<div class="sidebar">
    <div class="logo">Library Manager</div>
    <a href="javascript:void(0)" id="books-tab" class="nav-item active" onclick="loadUserTab('UserDashboardServlet', this)">
        <i class="fas fa-book"></i> Browse Books
    </a>
    <a href="javascript:void(0)" id="history-tab" class="nav-item" onclick="loadUserTab('UserHistoryServlet', this)">
        <i class="fas fa-history"></i> My History
    </a>
    <a href="javascript:void(0)" id="res-tab" class="nav-item" onclick="loadUserTab('MyReservationsServlet', this)">
        <i class="fas fa-calendar-check"></i> My Reservations
    </a>
    <a href="javascript:void(0)" id="profile-tab" class="nav-item" onclick="loadUserTab('UserProfileServlet', this)">
        <i class="fas fa-user"></i> My Profile
    </a>
    <a href="LogoutServlet" class="nav-item" style="color: #ff4444; margin-top: 40px;">
        <i class="fas fa-sign-out-alt"></i> Sign Out
    </a>
</div>

<div class="main-content">
    <h1>Welcome back, <%= currentUser.getName() %>!</h1>

    <div id="tab-container">
        <%
            List<Book> books = (List<Book>) request.getAttribute("bookList");
            List<Transaction> history = (List<Transaction>) request.getAttribute("borrowHistory");
            List<Map<String, String>> resList = (List<Map<String, String>>) request.getAttribute("reservationList");
            User profileData = (User) request.getAttribute("profileInfo");
            Double totalFines = (Double) request.getAttribute("totalFines");

            if (books != null) {
        %>
        <h2>Browse Library</h2>
        <table class="book-table">
            <thead><tr><th>Title</th><th>Author</th><th>Category</th><th>Availability</th><th>Action</th></tr></thead>
            <tbody>
            <% for(Book b : books) { %>
            <tr>
                <td><%= b.getTitle() %></td>
                <td><%= b.getAuthor() %></td>
                <td><%= b.getCategory() %></td>
                <td><span class="badge <%= b.getAvailableCopies() > 0 ? "badge-success" : "badge-warning" %>"><%= b.getAvailableCopies() %> / <%= b.getTotalCopies() %></span></td>
                <td><button class="btn-primary" style="padding: 8px 12px;" onclick="reserveBook(<%= b.getBookId() %>)">Reserve</button></td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <%
        } else if (history != null) {
        %>
        <h2>My Borrowing History</h2>
        <table class="book-table">
            <thead><tr><th>Book Title</th><th>Issue Date</th><th>Due Date</th><th>Status</th><th>Fine</th></tr></thead>
            <tbody>
            <% for(Transaction t : history) { %>
            <tr>
                <td><%= t.getBookTitle() %></td>
                <td><%= t.getIssueDate() %></td>
                <td><%= t.getDueDate() %></td>
                <td><span class="badge"><%= t.getStatus() %></span></td>
                <td>
                    <div style="color: <%= t.getFineAmount() > 0 ? "#c62828" : "inherit" %>; font-weight: bold;">
                        LKR <%= String.format("%.2f", t.getFineAmount()) %>
                    </div>
                    <% if(t.getFineAmount() > 0) { %>
                    <button class="payment-btn" onclick="openPayment('<%= t.getTransactionId() %>', '<%= t.getBookTitle() %>', '<%= t.getFineAmount() %>', '<%= t.getIssueDate() %>')">Pay Fine</button>
                    <% } %>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <%
        } else if (resList != null) {
        %>
        <h2 style="margin-top: 0;">My Reservations</h2>
        <table class="book-table">
            <thead><tr><th>Book Title</th><th>Reserved Date</th><th>Status</th></tr></thead>
            <tbody>
            <% for(Map<String, String> r : resList) { %>
            <tr><td><%= r.get("title") %></td><td><%= r.get("date") %></td><td><span class="badge badge-warning"><%= r.get("status") %></span></td></tr>
            <% } %>
            </tbody>
        </table>
        <%
        } else if (profileData != null) {
        %>
        <h2>My Profile</h2>
        <div class="profile-grid">
            <div class="info-card">
                <h3>Account Details</h3>
                <p><strong>Name:</strong> <%= profileData.getName() %></p>
                <p><strong>Username:</strong> <%= profileData.getUsername() %></p>
                <p><strong>Email:</strong> <%= profileData.getEmail() %></p>
                <p><strong>Fines Due:</strong> <span style="color:red; font-size:1.2em">LKR <%= String.format("%.2f", totalFines) %></span></p>
                <% if(totalFines > 0) { %>
                <button class="payment-btn" style="width: 100%; padding: 12px; font-size: 1.1em;" onclick="alert('Please go to My History tab to pay specific book fines.')">Clear Total Balance</button>
                <% } %>
            </div>
            <div class="info-card">
                <h3>Update Password</h3>
                <form onsubmit="updatePassword(event)">
                    <input type="password" name="currentPassword" class="form-control" placeholder="Current Password" required>
                    <input type="password" name="newPassword" class="form-control" placeholder="New Password" required>
                    <input type="password" name="confirmPassword" class="form-control" placeholder="Confirm Password" required>
                    <button type="submit" class="btn-primary">Update Password</button>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</div>

<div id="paymentModal" class="modal">
    <div class="modal-content">
        <span class="close-modal" onclick="closePayment()">&times;</span>
        <h2 style="color: var(--primary-orange);"><i class="fas fa-credit-card"></i> Payment Gateway</h2>
        <p id="fineDisplay" style="font-weight: bold; font-size: 1.2em; margin: 10px 0;"></p>
        <form onsubmit="processPayment(event)">
            <input type="hidden" id="payTransId">
            <input type="hidden" id="payBookTitle">
            <input type="hidden" id="payFineAmt">

            <label>Card Number</label>
            <input type="text" class="form-control" placeholder="1234 5678 9101 1121" maxlength="16" required pattern="\d{16}">
            <div style="display:flex; gap:10px; margin-top: 10px;">
                <div style="flex:1"><label>Expiry</label><input type="text" class="form-control" placeholder="MM/YY" required pattern="\d{2}/\d{2}"></div>
                <div style="flex:1"><label>CVV</label><input type="password" class="form-control" placeholder="***" maxlength="3" required pattern="\d{3}"></div>
            </div>
            <button type="submit" class="btn-primary" style="background-color: #27ae60;">Authorize Payment</button>
        </form>
    </div>
</div>

<script>
    function initializeDashboard() {
        setTimeout(() => loadUserTab('UserDashboardServlet', document.getElementById('books-tab')), 1000);
    }

    function loadUserTab(url, el) {
        if(el) {
            document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
            el.classList.add('active');
        }
        const container = document.getElementById('tab-container');
        container.classList.add('loading-state');
        fetch(url).then(res => res.text()).then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const newContent = doc.getElementById('tab-container');
            if(newContent) container.innerHTML = newContent.innerHTML;
            container.classList.remove('loading-state');
        });
    }

    function openPayment(id, title, amt, date) {
        document.getElementById('payTransId').value = id;
        document.getElementById('payBookTitle').value = title;
        document.getElementById('payFineAmt').value = amt;
        document.getElementById('fineDisplay').innerText = "Total Payable: LKR " + parseFloat(amt).toFixed(2);
        document.getElementById('paymentModal').style.display = "block";
    }

    function closePayment() { document.getElementById('paymentModal').style.display = "none"; }

    function processPayment(event) {
        event.preventDefault();
        const {jsPDF} = window.jspdf;
        const transId = document.getElementById('payTransId').value;
        const bookTitle = document.getElementById('payBookTitle').value;
        const fineAmt = document.getElementById('payFineAmt').value;

        fetch('ProcessFinePaymentServlet', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'transactionId=' + encodeURIComponent(transId) +
                '&amount=' + encodeURIComponent(fineAmt) +
                '&source=user'
        }).then(res => {
            if (res.ok) {
                const doc = new jsPDF();
                doc.setFontSize(22);
                doc.setTextColor(230, 126, 34);
                doc.text("LIBRARY MANAGEMENT SYSTEM", 105, 20, {align: "center"});
                doc.setFontSize(14);
                doc.setTextColor(0, 0, 0);
                doc.text("OFFICIAL PAYMENT RECEIPT", 105, 35, {align: "center"});
                doc.line(20, 40, 190, 40);
                doc.text("Member Name: <%= currentUser.getName() %>", 20, 55);
                doc.text("Receipt ID: #PAY-" + transId, 20, 65);
                doc.text("Book Title: " + bookTitle, 20, 75);
                doc.text("Paid On: " + new Date().toLocaleString(), 20, 85);
                doc.setFontSize(18);
                doc.text("Total Paid: LKR " + parseFloat(fineAmt).toFixed(2), 20, 105);
                doc.save("Library_Receipt_" + transId + ".pdf");

                alert("Payment Confirmed and Database Updated!");
                closePayment();
                loadUserTab('UserHistoryServlet', document.getElementById('history-tab'));
            } else {
                alert("Database update failed. Please contact the librarian.");
            }
        });
    }

        function updatePassword(event) {
        event.preventDefault();
        const params = new URLSearchParams(new FormData(event.target));
        fetch('UserProfileServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        }).then(res => res.text()).then(msg => alert(msg));
    }

    function reserveBook(id) {
        fetch('ReservationServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'bookId=' + id
        }).then(res => {
            if(res.ok) alert("Book Reserved Successfully!");
            else alert("Could not reserve book.");
        });
    }
</script>
</body>
</html>