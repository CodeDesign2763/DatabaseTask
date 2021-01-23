/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс MainForm
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
 
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.JButton;
import javax.swing.SwingConstants;
import javax.swing.JOptionPane;
import java.awt.GridLayout;
import javax.swing.JPanel;
import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import java.awt.Color;
import java.awt.event.*;

class MainForm extends JFrame implements ActionListener 
{
	private JLabel LInfo;
	private JPanel centralpanel;
	private JButton SpecButton;
	private JButton OlympButton;
	private JButton RatingButton;
	private JButton OrderButton;
	private db_connection_iface db_con;
	
	/* Вспомогательные формы */
	private SpecialityForm SpecForm;
	//private OlympiadForm OlympForm;
	
	
	public void setDBcon(db_connection_iface dbc)
	{
		SpecForm=new SpecialityForm("Таблица Speciality",dbc);
		//OlympForm=new OlympiadForm("Таблица Olympiad",dbc);
		db_con=dbc;
	}
	
	@Override
	public void actionPerformed(ActionEvent e)
	{
		if (e.getSource()==SpecButton) {
			SpecForm.setVisible(true);
			SpecForm.setDBcon(db_con);
			SpecForm.reset();
		}
	}
	
	public MainForm(String title)
	{
		/* Настройка графического интерфейса */
		setTitle(title);
		centralpanel=new JPanel(new GridLayout(5,1,10,10));
		centralpanel.setBorder(
		BorderFactory.createEmptyBorder(10, 10, 10, 10));
		LInfo=new JLabel("<html>ЛР №5 по дисциплине БД <br>"
		+"Выполнил: студент группы ВТВ-467 <br>"
		+"А. В. Чернокрылов <br>"
		+"Проверил: к. т. н. <br>"
		+"А. А. Соколов"
		+"</html>");
		centralpanel.add(LInfo);
		SpecButton=new JButton("Таблица Speciality");
		centralpanel.add(SpecButton);
		OlympButton=new JButton("Таблица Olympiad");
		centralpanel.add(OlympButton);
		RatingButton=new JButton("Рейтинг абитуриентов");
		centralpanel.add(RatingButton);
		OrderButton=new JButton(
		"Список лиц, рекомендованных к зачислению");
		centralpanel.add(OrderButton);
		add(centralpanel);
		
		/* Нажатие кнопок */
		SpecButton.addActionListener(this);
		
		/* Блокировка кнопок */
		OlympButton.setEnabled(false);
		RatingButton.setEnabled(false);
		OrderButton.setEnabled(false);
		
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		pack();
		setResizable(false);
		setVisible(false);
		/* Действия при закрытии окна */
		this.requestFocusInWindow();
		this.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				db_con.disconnect();
				System.exit(0);
			}
		});
	}
}
