/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Интерфейс db_proc_iface
 * 
 * Вспомогательный интерфейс для обработки данных
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

interface db_proc_iface {
	public default void fill_list_w_qr(query_result qr, 
	DefaultListModel<String> dlm)
	{
		dlm.clear();
		for (String str : qr.get_list()) {
			dlm.addElement(str);
		}
	}
	public default void fill_combobox_w_qr(query_result qr, 
	DefaultComboBoxModel<String> dcbm)
	{
		dcbm.removeAllElements();
		for (String str : qr.get_list()) {
			dcbm.addElement(str);
		}
	}

}
