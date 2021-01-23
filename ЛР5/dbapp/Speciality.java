/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс Speciality
 * 
 * Используется для хранения информации о ходе подключения к БД
 * 
 * Версия 1
 * 
 * 20.01.2021
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
class Speciality {
	private String specialityCode;
	private int subjectVips;
	private String name;
	public String getSpecialityCode() {
		return specialityCode;
	}
	public int getSubjectVips() {
		return subjectVips;
	}
	public String getName() {
		return name;
	}
	public Speciality(String sc, int sv, String n) {
		specialityCode=sc;
		subjectVips=sv;
		name=n;
	}
}

