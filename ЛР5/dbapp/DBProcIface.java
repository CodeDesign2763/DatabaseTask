/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Интерфейс DBProcIface
 * 
 * Вспомогательный интерфейс для вывода данных
 * полученных от БД
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
 
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

interface DBProcIface {
	/* Заполнить JList содержимым QueryResults */
	public default void fillListWQueryResults(QueryResult qr, 
	DefaultListModel<String> dlm) {
		dlm.clear();
		for (String str : qr.getList()) {
			dlm.addElement(str);
		}
	}
	/* Заполнить JComboBox содержимым QueryResults */
	public default void fillComboBoxWQueryResults(QueryResult qr, 
	DefaultComboBoxModel<String> dcbm) {
		dcbm.removeAllElements();
		for (String str : qr.getList()) {
			dcbm.addElement(str);
		}
	}

}
