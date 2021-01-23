/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс pgsql_db_connection реализующий соединение с СУБД
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

class pgsql_db_connection implements db_connection_iface {
	private Connection connection;
	private Statement statement;
	private ResultSet resultset;
	public void pgsql_db_connection(){
		connection=null;
		statement=null;
		resultset=null;
	}
	@Override 
	public connection_result connect(String na, String port, 
	String user, String password, String dbname)
	{
		boolean f=false;
		String output="";
		String db_url="jdbc:postgresql://"+na+":"+port+"/"+dbname;
		System.out.println(db_url+"\n"+user+"\n"+password);
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
				statement=connection.createStatement();
			} 
			else
			output=output
			+ " Ошибка при подключении к базе данных!";
		} 
		catch (SQLException e) {
			output=output+" Не удалось подключиться к базе данных!";
		}
		System.out.println(output);
		return new connection_result(f,output);
	}
	@Override
	public connection_result disconnect()
	{
		try { resultset.close(); } catch (Exception e) {}
		try { statement.close(); } catch (Exception e) {}
		try { connection.close(); } catch (Exception e) {}
			System.out.println("БД отключена");
		return new connection_result(true, "БД отключена");
	}
	@Override
	public query_result sql_function(String query,String[] atr) {
		ArrayList<String> list1=new ArrayList<String>();
		String str;
		boolean f=true;
		try {
		resultset=statement.executeQuery(
		query);
		while (resultset.next())
			{
				str="";
				for (int i=0;i<atr.length;i++)
				{
					str=str+resultset.getString(atr[i])+" ";
				}
				list1.add(str);
			}
		}
		catch (Exception E) {f=false;}
		return new query_result(f,list1);
	}
	
	@Override
	public query_result sql_function_single(String query,String atr) {
	ArrayList<String> list1=new ArrayList<String>();
	boolean f=true;
	try {
		resultset=statement.executeQuery(
		query);
		while (resultset.next())
		{
			list1.add(resultset.getString(atr));
		}
	}
	catch (Exception E) {f=false;}
	
	return new query_result(f,list1);
	}
	@Override
	public boolean sql_procedure(String query)
	{
		boolean f=true;
		try {
			statement.executeUpdate(query);
		}
		catch (Exception E) {f=false;}
		return f;
	}
}
