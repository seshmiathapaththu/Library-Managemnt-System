package com.library.model;

import java.sql.Date;

public class Transaction {

    private int transactionId;
    private int userId;
    private String username;
    private int bookId;
    private String bookTitle;
    private Date issueDate;
    private Date dueDate;
    private Date returnDate;
    private String status;
    private double fineAmount;


    public Transaction() {}


    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }


    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }


    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }


    public double getFineAmount() { return fineAmount; }
    public void setFineAmount(double fineAmount) { this.fineAmount = fineAmount; }


    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public Date getIssueDate() { return issueDate; }
    public void setIssueDate(Date issueDate) { this.issueDate = issueDate; }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}