/*
 * Учебное задание по дисциплине БД
 * Программа, демонстрирующая взаимодействие с СУБД PostgreSQL
 * на языке программирования Java

 * Версия 1
 * 
 * 21.01.2021
 * 
 * Для запуска:
 * java -cp postgresql-42.2.18.jar:. TestConnection
 * 
 */

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
public class TestConnection {
	/* Константы для подключения */
	static final String DB_URL = 
   "jdbc:postgresql://127.0.0.1:5432/admission_office";
    static final String USER = "postgres";
    static final String PASS = "Пароль";
	public static void main(String[] argv) {
	System.out.println(
	"Проверка подключения к PostgreSQL при помощи JDBC");
	
	/* Регистрация экземпляра драйвера менеджером */
	/* путем стат. инициализации */
 	try {
		Class.forName("org.postgresql.Driver");
	} catch (ClassNotFoundException e) {
		System.out.println("Ошибка! Драйвер PostgreSQL не найден!");
		e.printStackTrace();
	}
	System.out.println(
	"JDBC-драйвер PostgreSQL успешно зарегистрирован");
	/* Подключение к БД */
	Connection connection = null;
	Statement statement=null;
	ResultSet resultset=null;
	try {
		connection = DriverManager
		.getConnection(DB_URL, USER, PASS);
			System.out.println(
			"Вы успешно подключились к базе данных");
			System.out.println(
			"Названия стран из таблицы citizenship:");
			/* Выполнение запросов */
			/* Выведем список стран из таблицы Citizenship */
			statement=connection.createStatement();
			/* .executeQuery возвращает ResultSet
			 * Используется для запросов SELECT */
			resultset=statement.executeQuery(
			"select * from citizenship;");
			/* Если возвращать результат не требуется
			 * используется метод .executeUpdate */
			while (resultset.next()) {
				System.out.println(resultset.getString("name"));
			}
	} catch (SQLException e) {
		System.out.println("Ошибка при подключении к БД");
		System.out.println(e.getMessage());
	} finally {
		//Отключение от БД
		try { 
			resultset.close(); 
		} catch (Exception e) {}
		try { 
			statement.close(); 
		} catch (Exception e) {}
		try { 
			connection.close(); 
		} catch (Exception e) {}
		System.out.println("Вы отключились от БД");
	}
  }
}
