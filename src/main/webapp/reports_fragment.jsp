<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="report-content">
    <h3>${reportTitle}</h3>
    <hr>

    <c:if test="${not empty stats}">
        <div style="display: flex; gap: 20px; margin-bottom: 20px;">
            <div style="background: #eee; padding: 20px; border-radius: 8px; flex: 1;">
                <strong>Books:</strong> ${stats.totalBooks}
            </div>
            <div style="background: #d4edda; padding: 20px; border-radius: 8px; flex: 1;">
                <strong>Available:</strong> ${stats.availableBooks}
            </div>
            <div style="background: #fff3cd; padding: 20px; border-radius: 8px; flex: 1;">
                <strong>Fines Collected:</strong> LKR ${fn:replace(stats.totalFines, '$', '')}
            </div>
        </div>
    </c:if>

    <c:if test="${not empty data}">
        <table border="1" style="width: 100%; border-collapse: collapse; text-align: left;">
            <thead style="background: #f4f4f4;">
            <tr>
                <th>ID</th>
                <th>Detail</th>
                <th>User/Info</th>
                <th>Date/Time</th>
                <th>Status/Value</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="item" items="${data}">
                <tr>
                    <td>${item.id}</td>
                    <td>${item.title}</td>
                    <td>${item.person}</td>
                    <td>${item.date}</td>
                    <td>
                        <c:choose>
                            <c:when test="${reportTitle.contains('Payment')}">
                                <c:set var="cleanValue" value="${fn:replace(item.status, '$', '')}" />
                                <c:choose>
                                    <c:when test="${fn:contains(cleanValue, '(Card)')}">
                                        LKR ${cleanValue}
                                    </c:when>
                                    <c:otherwise>
                                        LKR ${cleanValue} (Card)
                                    </c:otherwise>
                                </c:choose>
                            </c:when>

                            <c:otherwise>
                                ${item.status}
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>
</div>