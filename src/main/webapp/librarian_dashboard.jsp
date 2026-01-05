<%@ page import="com.library.model.*, com.library.dao.*, java.util.*, java.util.stream.Collectors" %>
<%
    User librarian = (User) session.getAttribute("user");
    if (librarian == null || librarian.getRoleId() != 2) {
        response.sendRedirect("login.jsp");
        return;
    }

    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "users";

    BookDAO bookDAO = new BookDAO();
    UserDAO userDAO = new UserDAO();
    TransactionDAO transDAO = new TransactionDAO();
    ReservationDAO resDAO = new ReservationDAO();

    List<Book> bookList = (List<Book>) request.getAttribute("bookList");
    if (bookList == null) bookList = bookDAO.getAllBooks();

    List<User> userList = (List<User>) request.getAttribute("userList");
    if (userList == null) {
        userList = userDAO.getAllUsers().stream()
                .filter(u -> u.getRoleId() == 3)
                .collect(Collectors.toList());
    }

    List<Transaction> transList = (List<Transaction>) request.getAttribute("transList");
    if (transList == null) transList = transDAO.getAllTransactions();

    List<Reservation> resList = (List<Reservation>) request.getAttribute("resList");
    if (resList == null) resList = resDAO.getAllReservations();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Library Manager | Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-orange: #f39c12;
            --sidebar-dark: #1a1a1a;
            --body-bg: #f8f9fa;
            --success-green: #2ecc71;
            --error-red: #e74c3c;
            --text-muted: #7f8c8d;
            --payment-blue: #3498db;
        }

        body { font-family: 'Segoe UI', sans-serif; margin: 0; display: flex; background: var(--body-bg); color: #333; }

        .sidebar {
            width: 260px;
            background: var(--sidebar-dark);
            color: white;
            height: 100vh;
            position: fixed;
            padding: 20px 15px;
            box-sizing: border-box;
        }
        .logo { font-size: 24px; color: var(--primary-orange); font-weight: bold; padding: 0 10px; margin-bottom: 40px; }

        .nav-item {
            padding: 12px 20px;
            display: block;
            text-decoration: none;
            color: #ffffff;
            font-size: 16px;
            transition: 0.2s;
            margin-bottom: 8px;
            border-radius: 12px;
        }
        .nav-item:hover { color: white; background: #262626; }

        .nav-item.active {
            background: var(--primary-orange);
            color: white;
        }

        .nav-item.sign-out {
            color: var(--error-red) !important;
            margin-top: 50px;
        }
        .nav-item i { margin-right: 15px; width: 20px; text-align: center; }

        .main-content { flex: 1; margin-left: 260px; padding: 40px; min-height: 100vh; }
        .welcome-msg { font-size: 28px; font-weight: bold; margin-bottom: 30px; }
        .card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        h3 { font-size: 22px; margin: 0; color: #2c3e50; }

        .alert { padding: 15px; margin-bottom: 25px; border-radius: 8px; font-weight: bold; font-size: 14px; }
        .alert-success { background: #e8f5e9; color: var(--success-green); border-left: 5px solid var(--success-green); }
        .alert-error { background: #fdeaea; color: var(--error-red); border-left: 5px solid var(--error-red); }

        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { text-align: left; background: #fdfdfd; padding: 15px; color: var(--text-muted); font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 18px 15px; border-bottom: 1px solid #f1f1f1; font-size: 14px; }

        .btn { padding: 10px 18px; border-radius: 6px; border: none; cursor: pointer; font-weight: bold; transition: 0.2s; font-size: 13px; }
        .btn-add { background: var(--primary-orange); color: white; }
        .btn-issue { background: #2980b9; color: white; }
        .btn-danger { background: var(--error-red); color: white; }
        .btn-pay { background: var(--payment-blue); color: white; margin-left: 5px; }

        .action-icon { background: none; border: none; cursor: pointer; font-size: 18px; margin-left: 10px; transition: 0.2s; vertical-align: middle; }
        .action-icon:hover { transform: scale(1.2); }

        .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        .badge-active { background: #e8f5e9; color: #27ae60; }
        .badge-inactive { background: #fdeaea; color: #c62828; }
        .badge-warning { background: #fff3e0; color: #ef6c00; }

        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); }
        .modal-content { background-color: #fff; margin: 5% auto; padding: 30px; border-radius: 12px; width: 450px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .modal-header { border-bottom: 1px solid #eee; padding-bottom: 15px; margin-bottom: 20px; font-size: 20px; font-weight: bold; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #555; }
        .form-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; }
        .modal-footer { text-align: right; border-top: 1px solid #eee; padding-top: 20px; margin-top: 20px; }
    </style>
</head>
<body>

<div class="sidebar">
    <div class="logo">Library Manager</div>

    <a href="LibrarianDashboardServlet?tab=users" class="nav-item <%= "users".equals(activeTab) ? "active" : "" %>">
        <i class="fas fa-users"></i> Users
    </a>

    <a href="LibrarianDashboardServlet?tab=books" class="nav-item <%= "books".equals(activeTab) ? "active" : "" %>">
        <i class="fas fa-book"></i> Books
    </a>

    <a href="LibrarianDashboardServlet?tab=transactions" class="nav-item <%= "transactions".equals(activeTab) ? "active" : "" %>">
        <i class="fas fa-exchange-alt"></i> Reports
    </a>

    <a href="LibrarianDashboardServlet?tab=reservations" class="nav-item <%= "reservations".equals(activeTab) ? "active" : "" %>">
        <i class="fas fa-clock"></i> Reservations
    </a>

    <a href="LogoutServlet" class="nav-item sign-out">
        <i class="fas fa-sign-out-alt"></i> Sign Out
    </a>
</div>

<div class="main-content">
    <div class="welcome-msg">Welcome back, <%= librarian.getName().toLowerCase() %>!</div>

    <% if(request.getParameter("success") != null) { %>
    <div class="alert alert-success"><i class="fas fa-check-circle"></i> Success: <%= request.getParameter("success").replace("_", " ") %></div>
    <% } %>
    <% if(request.getParameter("error") != null) { %>
    <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Error: <%= request.getParameter("error").replace("_", " ") %></div>
    <% } %>

    <div class="card">
        <% if ("users".equals(activeTab)) { %>
        <div class="card-header">
            <h3>Member Management</h3>
            <button class="btn btn-add" onclick="openModal('addMemberModal')">+ Add New Member</button>
        </div>
        <table>
            <thead><tr><th>Name</th><th>Username</th><th>Email</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
            <% for(User u : userList) { %>
            <tr>
                <td><%= u.getName() %></td>
                <td><%= u.getUsername() %></td>
                <td><%= u.getEmail() %></td>
                <td><span class="badge <%= "Active".equals(u.getStatus()) ? "badge-active" : "badge-inactive" %>"><%= u.getStatus() %></span></td>
                <td>
                    <button class="action-icon" style="color: var(--primary-orange)" onclick="toggleStatus(<%= u.getUserId() %>, '<%= u.getStatus() %>')">
                        <i class="fas fa-toggle-<%= "Active".equals(u.getStatus()) ? "on" : "off" %>"></i>
                    </button>
                    <button class="action-icon" style="color: var(--error-red)" onclick="confirmDeleteUser(<%= u.getUserId() %>, '<%= u.getName().replace("'", "\\'") %>')">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <% } else if ("transactions".equals(activeTab)) { %>
        <div class="card-header">
            <h3>Lending Management</h3>
            <button class="btn btn-issue" onclick="openModal('issueBookModal')">Issue New Book</button>
        </div>
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Member</th>
                <th>Book</th>
                <th>Issue Date</th>
                <th>Return Date</th> <th>Due Date</th>
                <th>Fine</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <% for(Transaction t : transList) { %>
            <tr>
                <td><%= t.getTransactionId() %></td>
                <td><%= t.getUsername() %></td>
                <td><%= t.getBookTitle() %></td>
                <td><%= t.getIssueDate() %></td>


                <td>
                    <%= (t.getReturnDate() != null) ? t.getReturnDate() : "<span style='color:var(--text-muted); font-style:italic;'>Not Returned</span>" %>
                </td>

                <td><%= t.getDueDate() %></td>

                <td style="color: <%= t.getFineAmount() > 0 ? "var(--error-red)"  : "var(--success-green)" %>; font-weight: bold;">
                    LKR <%= String.format("%.2f", t.getFineAmount()) %>
                </td>

                <td>
        <span class="badge <%= "Issued".equals(t.getStatus()) ? "badge-warning" : "badge-active" %>">
            <%= t.getStatus() %>
        </span>
                </td>

                <td>
                    <% if("Issued".equals(t.getStatus())) { %>
                    <button class="btn btn-add" onclick="returnBook(<%= t.getTransactionId() %>)">Return Book</button>
                    <% } %>

                    <% if(t.getFineAmount() > 0) { %>
                    <button class="btn btn-pay" onclick="openDetailedPaymentModal(<%= t.getTransactionId() %>, <%= t.getFineAmount() %>, '<%= t.getUsername().replace("'", "\\'") %>', '<%= t.getBookTitle().replace("'", "\\'") %>')">
                        <i class="fas fa-receipt"></i> Pay Fine
                    </button>
                    <% } else { %>
                    <span style="color: var(--success-green); font-weight: bold; margin-left: 10px;">
            <i class="fas fa-check-circle"></i> Cleared
        </span>
                    <% } %>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>

        <% } else if ("reservations".equals(activeTab)) { %>
        <div class="card-header">
            <h3>Pending Reservations</h3>
        </div>
        <table>
            <thead>
            <tr>
                <th>Member</th>
                <th>Book Title</th>
                <th>Reserved Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% if (resList == null || resList.isEmpty()) { %>
            <tr><td colspan="5" style="text-align:center;">No pending reservations found.</td></tr>
            <% } else {
                for(Reservation r : resList) { %>
            <tr>
                <td><%= r.getUsername() %></td>
                <td><%= r.getBookTitle() %></td>
                <td><%= r.getReservationDate() %></td>
                <td><span class="badge badge-warning"><%= r.getStatus() %></span></td>
                <td id="res-actions-<%= r.getReservationId() %>">
                    <button class="btn btn-add" onclick="handleReservation(<%= r.getReservationId() %>, 'Completed')">
                        <i class="fas fa-check"></i> Approve
                    </button>
                    <button class="btn btn-danger" style="margin-left:5px;" onclick="handleReservation(<%= r.getReservationId() %>, 'Cancelled')">
                        <i class="fas fa-times"></i> Cancel
                    </button>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>

        <% } else { %>
        <div class="card-header">
            <h3>Library Catalog</h3>
            <button class="btn btn-add" onclick="openModal('addBookModal')">+ Add New Book</button>
        </div>
        <table>
            <thead><tr><th>Book ID</th><th>Title</th><th>Author</th><th>ISBN</th><th>Available</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
            <% for(Book b : bookList) { if("Inactive".equals(b.getStatus())) continue; %>
            <tr>
                <td><%= b.getBookId() %></td>
                <td style="font-weight:bold"><%= b.getTitle() %></td>
                <td><%= b.getAuthor() %></td>
                <td><%= b.getIsbn() %></td>
                <td><%= b.getAvailableCopies() %> / <%= b.getTotalCopies() %></td>
                <td><span class="badge <%= "Available".equals(b.getStatus()) ? "badge-active" : "badge-inactive" %>"><%= b.getStatus() %></span></td>
                <td>
                    <button type="button"
                            onclick="deleteBook(<%= b.getBookId() %>, '<%= b.getTitle().replace("'", "\\'") %>')"
                            style="background:none; border:none; color:#e74c3c; cursor:pointer;">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>
</div>

<div id="addBookModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">Add New Book</div>
        <form action="AddBookServlet" method="POST">
            <div class="form-group"><label>Book Title</label><input type="text" name="title" required></div>
            <div class="form-group"><label>Author</label><input type="text" name="author" required></div>
            <div class="form-group"><label>ISBN</label><input type="text" name="isbn" required></div>
            <div class="form-group"><label>Category</label><input type="text" name="category" required></div>
            <div class="form-group"><label>Total Copies</label><input type="number" name="copies" value="1" min="1" required></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" onclick="closeModal('addBookModal')">Cancel</button>
                <button type="submit" class="btn btn-add">Save Book</button>
            </div>
        </form>
    </div>
</div>

<div id="addMemberModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">Add New Member</div>
        <form action="AddMemberServlet" method="POST">
            <div class="form-group"><label>Full Name</label><input type="text" name="name" required></div>
            <div class="form-group"><label>Username</label><input type="text" name="username" required></div>
            <div class="form-group"><label>Email Address</label><input type="email" name="email" required></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" onclick="closeModal('addMemberModal')">Cancel</button>
                <button type="submit" class="btn btn-add">Create Account</button>
            </div>
        </form>
    </div>
</div>

<div id="issueBookModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">Issue Book</div>
        <form action="IssueBookServlet" method="POST">
            <div class="form-group"><label>Member ID</label><input type="number" name="userId" required></div>
            <div class="form-group"><label>Book ID</label><input type="number" name="bookId" required></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" onclick="closeModal('issueBookModal')">Cancel</button>
                <button type="submit" class="btn btn-add">Issue</button>
            </div>
        </form>
    </div>
</div>

<div id="detailedPaymentModal" class="modal">
    <div class="modal-content" style="width: 500px;">
        <div class="modal-header"><i class="fas fa-shield-alt" style="color:var(--success-green)"></i> Secure Fine Payment</div>
        <form id="detailedPaymentForm" action="ProcessFinePaymentServlet" method="POST">
            <input type="hidden" id="detTransId" name="transactionId">
            <input type="hidden" id="detMemberName">
            <input type="hidden" id="detBookTitle">
            <input type="hidden" name="source" value="librarian">


            <div class="form-group">
                <label>Billing Details</label>
                <div style="background: #fcfcfc; border: 1px dashed #ddd; padding: 10px; font-size: 13px; border-radius: 5px;">
                    <p style="margin: 5px 0;">Member: <span id="spanMember" style="font-weight: bold;"></span></p>
                    <p style="margin: 5px 0;">Book: <span id="spanBook" style="font-weight: bold;"></span></p>
                    <%-- UPDATED CURRENCY TO LKR IN MODAL DISPLAY --%>
                    <p style="margin: 5px 0; color: var(--error-red);">Current Fine: <span id="spanAmount" style="font-weight: bold;"></span></p>
                </div>
            </div>

            <div class="form-group">
                <label>Amount to Pay (LKR)</label>
                <input type="number" id="payAmountInput" name="amount" step="0.01" class="form-control" placeholder="Enter payment amount" required>
            </div>

            <div class="form-group">
                <label>Cardholder Name</label>
                <input type="text" placeholder="Full Name on Card" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Card Number</label>
                <input type="text" placeholder="1234 5678 9101 1121" maxlength="16" class="form-control" required>
            </div>
            <div style="display:flex; gap:10px;">
                <div class="form-group" style="flex:2;"><label>Expiry</label><input type="text" class="form-control" placeholder="MM/YY" required></div>
                <div class="form-group" style="flex:1;"><label>CVV</label><input type="password" class="form-control" placeholder="***" maxlength="3" required></div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-danger" onclick="closeModal('detailedPaymentModal')">Cancel</button>
                <button type="button" class="btn btn-add" onclick="processPaymentWithDetailedBill()">Pay & Download Bill</button>
            </div>
        </form>
    </div>
</div>

<script>
    function deleteBook(bookId, bookTitle) {
        if (confirm("Are you sure you want to delete: '" + bookTitle + "'?")) {
            // Use fetch to call the servlet
            fetch("BookServlet?action=delete&bookId=" + bookId + "&isLibrarian=true")
                .then(response => {
                    if (response.ok) {
                        alert("Book deleted successfully!");
                        // Reload the page to refresh the book list
                        location.reload();
                    } else {
                        throw new Error("Deletion failed. The book may be currently issued.");
                    }
                })
                .catch(err => {
                    alert(err.message);
                });
        }
    }

    function handleReservation(resId, status) {
        const action = status === 'Completed' ? 'approve' : 'cancel';
        if(confirm("Are you sure you want to " + action + " this reservation?")) {
            const container = document.getElementById('res-actions-' + resId);
            if(container) {
                container.innerHTML = '<span style="color:var(--text-muted); font-style:italic;"><i class="fas fa-spinner fa-spin"></i> Processing...</span>';
            }
            window.location.href = "UpdateReservationServlet?id=" + resId + "&status=" + status;
        }
    }

    function toggleStatus(id, current) {
        if(confirm("Change status?")) window.location.href = "ToggleUserStatusServlet?id=" + id + "&current=" + current;
    }

    function confirmDeleteUser(id, name) {
        if(confirm("Delete " + name + "?")) window.location.href = "DeleteUserServlet?id=" + id;
    }

    function returnBook(id) {
        if(confirm("Process return?")) {
            fetch('ReturnBookServlet', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'transactionId=' + id
            }).then(res => { if(res.ok) location.reload(); });
        }
    }

    function openDetailedPaymentModal(id, amount, member, book) {
        document.getElementById('detTransId').value = id;
        document.getElementById('detMemberName').value = member;
        document.getElementById('detBookTitle').value = book;

        document.getElementById('spanMember').innerText = member;
        document.getElementById('spanBook').innerText = book;
        document.getElementById('spanAmount').innerText = "LKR " + amount.toFixed(2);

        document.getElementById('payAmountInput').value = parseFloat(amount).toFixed(2);

        openModal('detailedPaymentModal');
    }

    function processPaymentWithDetailedBill() {
        var id = document.getElementById('detTransId').value;
        var member = document.getElementById('detMemberName').value;
        var book = document.getElementById('detBookTitle').value;
        var amount = document.getElementById('payAmountInput').value;
        var date = new Date().toLocaleString();

        if(!amount || amount <= 0) {
            alert("Please enter a valid amount.");
            return;
        }

        var bill = "=========================================\n" +
            "       LIBRARY MANAGEMENT SYSTEM\n" +
            "            OFFICIAL RECEIPT\n" +
            "=========================================\n" +
            "DATE: " + date + "\n" +
            "RECEIPT NO: #REC-" + id + "\n" +
            "MEMBER: " + member + "\n" +
            "BOOK: " + book + "\n" +
            "AMOUNT PAID: LKR " + parseFloat(amount).toFixed(2) + "\n" +
            "STATUS: PAYMENT RECORDED\n" +
            "=========================================";

        var element = document.createElement('a');
        var file = new Blob([bill], {type: 'text/plain'});
        element.href = URL.createObjectURL(file);
        element.download = "Bill_" + member.replace(/\s/g, '_') + "_" + id + ".txt";
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);

        document.getElementById('detailedPaymentForm').submit();
    }

    function openModal(id) { document.getElementById(id).style.display = "block"; }
    function closeModal(id) { document.getElementById(id).style.display = "none"; }
</script>
</body>
</html>