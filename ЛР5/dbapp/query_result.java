/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс query_result
 * Используется для хранения данных, возвращаемых
 * при помощи методов интерфейса db_connection_iface
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
class query_result{
	private boolean res;
	private ArrayList<String> ls;
	public query_result(boolean flag, ArrayList<String> list)
	{
		ls=list;
		res=flag;
	}
	public boolean get_result() {
		return res;
	}
	public ArrayList<String> get_list() {
		return ls;
	}
	public String get_string() {
		return ls.get(0);
	}
}
