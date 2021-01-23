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
interface DBConnectionIface
{
	/* Функция проверяет настройки соединения и в случае,
	 * если они корректны, сохраняет их для дальнейших 
	 * подключений, проводимых в автоматическом режиме
	 */
	public ConnectionResult checkConnection(String na, String port, 
	String user, String password, String dbname);
	
	/* Отключение от БД */
	public ConnectionResult disconnect();
	
	/* Взаимодействие с сущностью Speciality из БД */
	public QueryResult getSpecialityByCode(String code);
	public QueryResult getSpecialityCodeList();
	public boolean addSpeciality(Speciality sp);
	public boolean updateSpecialityByCode(String code, Speciality sp);
	public boolean deleteSpecialityByCode(String code);
	/* Взаимодействие с сущностью Subject */
	public QueryResult getSubjectNameList();
	public QueryResult getSubjectIDByName(String Name);
	
}
