<%@ page import="com.library.model.Book" %>
<%@ page import="java.util.List" %>

<style>
    .search-wrapper {
        display: flex;
        align-items: center;
        width: 100%;
        max-width: 400px;
        margin: 20px 0;
        border: 1px solid #ddd;
        border-radius: 25px;
        overflow: hidden;
        background: #fff;
    }
    .search-wrapper input {
        flex: 1;
        border: none;
        padding: 10px 20px;
        outline: none;
    }
    .search-btn {
        background: #e67e22;
        color: white;
        border: none;
        padding: 10px 20px;
        cursor: pointer;
    }

    .book-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    .book-table th { text-align: left; border-bottom: 2px solid #eee; padding: 12px; }
    .book-table td { padding: 12px; border-bottom: 1px solid #f1f1f1; }

    .modal-overlay { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); justify-content: center; align-items: center; }
    .modal-card { background: white; padding: 30px; border-radius: 20px; width: 400px; }
</style>

<div style="display: flex; justify-content: space-between; align-items: center;">
    <h2>Book Management</h2>
    <button onclick="document.getElementById('addBookModal').style.display='flex'"
            style="background:#e67e22; color:white; border:none; padding:10px 20px; border-radius:5px; cursor:pointer;">
        + Add New Book
    </button>
</div>

<div class="search-wrapper">
    <input type="text" id="searchInput" placeholder="Search by name..."
           onkeypress="if(event.key === 'Enter') performSearch()">
    <button class="search-btn" onclick="performSearch()">
        <i class="fas fa-search"></i>
    </button>
</div>

<table class="book-table">
    <thead>
    <tr>
        <th>Title</th><th>ISBN</th><th>Availability</th><th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<Book> booksList = (List<Book>) request.getAttribute("bookList");
        if(booksList != null && !booksList.isEmpty()) {
            for(Book b : booksList) {
    %>
    <tr>
        <td><%= b.getTitle() %></td>
        <td><%= b.getIsbn() %></td>
        <td><strong><%= b.getAvailableCopies() %></strong> / <%= b.getTotalCopies() %></td>
        <td>
            <form action="BookServlet" method="POST" style="display:inline;" onsubmit="return confirm('Delete this book?');">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="bookId" value="<%= b.getBookId() %>">
                <button type="submit" style="color:red; background:none; border:none; cursor:pointer;"><i class="fas fa-trash"></i></button>
            </form>
        </td>
    </tr>
    <% } } else { %>
    <tr><td colspan="4" style="text-align:center; padding:20px;">No books found.</td></tr>
    <% } %>
    </tbody>
</table>

<div id="addBookModal" class="modal-overlay">
    <div class="modal-card">
        <h3>Add New Book</h3>
        <form action="BookServlet" method="POST">
            <input type="hidden" name="action" value="add">
            <input type="text" name="title" placeholder="Title" required style="width:100%; margin-bottom:10px; padding:8px;">
            <input type="text" name="author" placeholder="Author" required style="width:100%; margin-bottom:10px; padding:8px;">
            <input type="text" name="isbn" placeholder="ISBN" required style="width:100%; margin-bottom:10px; padding:8px;">
            <input type="number" name="copies" placeholder="Copies" min="1" required style="width:100%; margin-bottom:15px; padding:8px;">
            <button type="submit" style="width:100%; background:#27ae60; color:white; padding:10px; border:none; border-radius:5px;">Add Book</button>
            <button type="button" onclick="document.getElementById('addBookModal').style.display='none'" style="width:100%; background:#8e8e8e; color:white; padding:10px; border:none; border-radius:5px; margin-top:5px;">Cancel</button>
        </form>
    </div>
</div>

<script>
    function performSearch() {
        const query = document.getElementById('searchInput').value;

        loadTab('ManageBooksServlet?searchQuery=' + encodeURIComponent(query), document.getElementById('books-tab'));
    }
</script>