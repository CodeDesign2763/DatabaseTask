/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Интерфейс db_connection_iface
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
 
import java.util.ArrayList;
interface db_connection_iface
{
	/* Подключение к БД */
	public connection_result connect(String na, String port, 
	String user, String password, String dbname);
	/* Отключение от БД */
	public connection_result disconnect();
	/* Функция возвращающая результат запроса SQL в виде
	 * экземпляра класса query_result, состоящего из 
	 * флага успешности действия и списка String 
	 * В качестве одного из аргументов поддерживает массив
	 * атрибутов сущности (string[])*/
	public query_result sql_function(String query,String[] atr);
	/* Та же самая функция, но на вход подается только 1 атрибут */
	public query_result sql_function_single(String query,String atr);
	/* Функция для запросов, не требующих вывода типа CREATE и т.п.
	 * Возвращает флаг успешности результата */
	public boolean sql_procedure(String query);
}
