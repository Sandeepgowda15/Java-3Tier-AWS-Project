<%@ page contentType="text/html;charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>

    <h1>Welcome, ${username}!</h1>

    <p>You have successfully logged in.</p>

    <br>

    <form method="post"
          action="${pageContext.request.contextPath}/logout">

        <input type="hidden"
               name="${_csrf.parameterName}"
               value="${_csrf.token}">

        <button type="submit">Logout</button>

    </form>

    <br>

    <a href="${pageContext.request.contextPath}/">
        Back to Home
    </a>

</body>
</html>
