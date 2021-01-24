/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс PGSQLDBConnection 
 * 
 * Реализует соединение с СУБД
 * PostgreSQL на основе интерфейса db_connection_iface
 * 
 * См. документацию к интерфейсу
 * 
 * Предназначен для соединения с базами данных.
 * Его использование позволяет предотвратить значительные
 * изменения в коде при смене СУБД
 * 
 * Версия 1
 * 
 * 21.01.2021
 * 
 * (C) 2021 by Alexander Chernokrylov <CodeDesign2763@gmail.com>
 *
 * This program is free software; 
 * you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2
 * as published by
 * the Free Software Foundation
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 */
 

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.lang.Exception;
import java.util.ArrayList;
import java.util.Properties;
import java.sql.PreparedStatement;

class PGSQLDBConnection implements DBConnectionIface {
	private Connection connection;
	private PreparedStatement preparedStatement;
	private ResultSet resultset;
	private Properties connProperties=new Properties();
	private String dbUrl;
	
	
	private static final String DATABASE_USER = "user";
	private static final String DATABASE_PASSWORD = "password";
	
	private void setConnectionProperties(String na, 
	String port, String user, String pw, String dbName) {
		connProperties.put(DATABASE_USER, user);
		connProperties.put(DATABASE_PASSWORD,pw);
		dbUrl="jdbc:postgresql://"+na+":"+port+"/"+dbName;
	}
	
	private ConnectionResult connectWithProps() {
		boolean f=false;
		String output="";
		
		/* Подключение к БД */
		try {
			connection = DriverManager.getConnection
			(dbUrl,connProperties);
			if (connection != null) {
				output=output
				+ " Вы успешно подключились к базе данных.";
				f=true;
				//statement=connection.createStatement();
			} 
			else
			output=output
			+ " Ошибка при подключении к базе данных!";
		} 
		catch (SQLException e) {
			output=output
			+" Не удалось подключиться к базе данных!";
		}
		return new ConnectionResult(f,output);
	}
	
	public void pgsql_db_connection(){
		connection=null;
		resultset=null;
	}
	public ConnectionResult checkConnection(String na, String port, 
	String user, String password, String dbname) {
		ConnectionResult cr=connect(na,port,user,password,dbname);
		if (cr.getResult()) 
			setConnectionProperties(na,port,user,password,dbname);
		disconnect();
		return cr;
	}
	
	private ConnectionResult connect(String na, String port, 
	String user, String password, String dbname) {
		boolean f=false;
		String message="";
		String output="";
		String db_url="jdbc:postgresql://"+na+":"+port+"/"+dbname;
		/* Регистрация экземпляра драйвера менеджером 
		путем стат. инициализации */
		try {
			Class.forName("org.postgresql.Driver");
		} 
		catch (ClassNotFoundException e) {
			output="Ошибка! Драйвер Postgresql не найден!";
		}
		output=output
		+" Драйвер PostgreSQL успешно зарегистрирован.";
		/* Подключение к БД */
		try {
			connection = DriverManager
			.getConnection(db_url, user,password);
			if (connection != null) {
				output=output
				+ " Вы успешно подключились к базе данных.";
				f=true;
				//statement=connection.createStatement();
			} 
			else
			output=output
			+ " Ошибка при подключении к базе данных!";
		} 
		catch (SQLException e) {
			output=output
			+" Не удалось подключиться к базе данных!";
		}
		return new ConnectionResult(f,output);
	}
	@Override
	public ConnectionResult disconnect() {
		try { 
			resultset.close(); 
		} catch (Exception e) {}
		try { 
			preparedStatement.close(); 
		} catch (Exception e) {}
		try { 
			connection.close(); 
		} catch (Exception e) {}
		return new ConnectionResult(true, "БД отключена");
	}
	
	@Override
	public QueryResult  getSpecialityByCode(String code) {
		String name="";
		String message="";
		int subjectVips=0;
		boolean f=true;
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса */
		try {
			preparedStatement=connection.prepareStatement(
			"SELECT name, subject_vips " 
			+"FROM speciality WHERE speciality_code=?;");
			preparedStatement.setString(1,code);
			resultset=preparedStatement.executeQuery();
			resultset.next();
			name=resultset.getString("name");
			subjectVips=resultset.getInt("subject_vips");
		} catch (SQLException e) {
			f=false; 
			message=e.getMessage();
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return new QueryResult(f,null,
		new Speciality(code,subjectVips,name),message);	
	}
	
	public QueryResult getSpecialityCodeList() {
		ArrayList<String> list1= new ArrayList<String>();
		boolean f=true;
		String message="";
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement=
			connection.prepareStatement(
			"SELECT speciality_code FROM speciality;");
			resultset=preparedStatement.executeQuery();
			while (resultset.next())
			{
				list1.add(resultset.getString("speciality_code"));
			}
		} catch (Exception e) {
			f=false;
			message=e.getMessage();
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return new QueryResult(f,list1,null,message);
	}
	
	public boolean addSpeciality(Speciality sp) {
		boolean f=true;
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement =connection.prepareStatement(
			"INSERT INTO speciality VALUES(?,?,?);");
			preparedStatement.setString(1,sp.getSpecialityCode());
			preparedStatement.setInt(2,sp.getSubjectVips());
			preparedStatement.setString(3,sp.getName());
			preparedStatement.execute();
			
		} catch (Exception e) {
			f=false;
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return f;
	}
	public boolean updateSpecialityByCode(String code, 
	Speciality sp) {
		boolean f=true;
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement=connection.prepareStatement(
			"UPDATE speciality SET subject_vips=?, name=? "
			+"WHERE speciality_code=?;");
			preparedStatement.setInt(1,sp.getSubjectVips());
			preparedStatement.setString(2,sp.getName());
			preparedStatement.setString(3,code);
			preparedStatement.execute();
		} catch (Exception e) {
			f=false;
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return f;
	}
	
	public boolean deleteSpecialityByCode(String code) {
		boolean f=true;
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement=connection.prepareStatement(
			"DELETE FROM speciality WHERE speciality_code=?;");
			preparedStatement.setString(1,code);
			preparedStatement.execute();
		} catch (Exception e) {
			f=false;
		}
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return f;
	}
	
	@Override
	public QueryResult getSubjectNameList() {
		ArrayList<String> list1= new ArrayList<String>();
		boolean f=true;
		String message="";
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement=connection.prepareStatement(
			"SELECT DISTINCT subject.name "
			+"FROM subject JOIN speciality"
			+" on subject.id=speciality.subject_vips;");
			resultset=preparedStatement.executeQuery();
			while (resultset.next())
			{
				list1.add(resultset.getString("name"));
			}
		} catch (Exception e) {
			f=false;
			message=e.getMessage();
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return new QueryResult(f,list1,null,message);
	}
	
	@Override
	public QueryResult getSubjectIDByName(String name) {
		ArrayList<String> list1= new ArrayList<String>();
		boolean f=true;
		String message="";
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement=connection.prepareStatement(
			"SELECT id FROM subject WHERE name=?;");
			preparedStatement.setString(1, name);
			resultset=preparedStatement.executeQuery();
			while (resultset.next())
			{
				list1.add(resultset.getString("id"));
			}
		} catch (Exception e) {
			f=false;
			message=e.getMessage();
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return new QueryResult(f,list1,null,message);
	}
	
	@Override
	public QueryResult getSubjectNameByID(int id) {
		ArrayList<String> list1= new ArrayList<String>();
		boolean f=true;
		String message="";
		/* Подключение к БД */
		f=f && connectWithProps().getResult();
		/* Выполнение запроса и обработка данных */
		try {
			preparedStatement=connection.prepareStatement(
			"SELECT name FROM subject WHERE id=?;");
			preparedStatement.setInt(1, id);
			resultset=preparedStatement.executeQuery();
			while (resultset.next())
			{
				list1.add(resultset.getString("name"));
			}
		} catch (Exception e) {
			f=false;
			message=e.getMessage();
		}
		
		/* Отключение от БД */
		disconnect();
		/* Возврат значения */
		return new QueryResult(f,list1,null,message);
	}
}
