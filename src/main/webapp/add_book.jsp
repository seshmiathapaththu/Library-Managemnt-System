<!DOCTYPE html>
<html>
<head>
    <title>Add New Book</title>
</head>
<body>
<h2>Add New Book to Inventory</h2>
<form action="BookServlet" method="post">
    <input type="hidden" name="action" value="add">
    <input type="text" name="title" placeholder="Book Title" required><br>
    <input type="text" name="author" placeholder="Author" required><br>
    <input type="text" name="isbn" placeholder="ISBN Number" required><br>
    <input type="number" name="copies" placeholder="Total Copies" required><br>
    <button type="submit">Save Book</button>
</form>
</body>
</html>