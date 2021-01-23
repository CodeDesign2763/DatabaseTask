/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс AuthForm
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
import javax.swing.JPasswordField;
import java.awt.Color;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
 
class AuthForm extends JFrame implements ActionListener 
{
	private JPanel centralpanel;
	private JTextField UserField=new JTextField(30);
	private JPasswordField PasswordField=new JPasswordField(30);
	private JTextField DBServerNAField=new JTextField(30);
	private JTextField DBServerPField=new JTextField(30);
	private JButton ConnectButton = new JButton("Подключиться");
	private JLabel ConnectionResult = new JLabel("Нет подключения");
	private JButton NextButton = new JButton("Далее");
	private db_connection_iface db_con=new pgsql_db_connection();
	private MainForm mainform_pointer;
	
	public void setMainFormPointer(MainForm mfp)	{
		this.mainform_pointer=mfp;
	}
	
	public db_connection_iface get_db_connection() {
		return this.db_con;
	}
	
	@Override
	public void actionPerformed(ActionEvent e)
	{
		connection_result res1;
		if (e.getSource()==ConnectButton) 
		{
			res1=db_con.connect(DBServerNAField.getText(),
			DBServerPField.getText(), 
			UserField.getText(),
			new String(PasswordField.getPassword()),
			"admission_office");

			if (res1.get_result()) 
			{
				ConnectionResult.setText(
				"Вы успешно подключились к БД!");
				NextButton.setEnabled(true);
				ConnectButton.setEnabled(false);
			}
			else
			{
				ConnectionResult.setText(
				"Ошибка при подключении к БД!");
				db_con.disconnect();
			}
		}
		else
		if (e.getSource()==NextButton)  
		{
			mainform_pointer.setVisible(true);
			mainform_pointer.setDBcon(db_con);
			this.setVisible(false);
		}
	}
	
	public AuthForm(String title)
	{
		setTitle(title);
		centralpanel=new JPanel(new GridLayout(7,1,10,10));
		centralpanel.setBorder(
		BorderFactory.createEmptyBorder(10, 10, 10, 10));
		UserField.setBorder(
		BorderFactory.createTitledBorder("Имя пользователя БД"));
		PasswordField.setBorder(
		BorderFactory.createTitledBorder("Пароль"));
		DBServerNAField.setBorder(
		BorderFactory.createTitledBorder("Адрес сервера"));
		DBServerPField.setBorder(
		BorderFactory.createTitledBorder("Порт"));
		ConnectionResult.setBorder(
		BorderFactory.createTitledBorder("Результат подключения"));
		centralpanel.add(UserField);
		centralpanel.add(PasswordField);
		centralpanel.add(DBServerNAField);
		centralpanel.add(DBServerPField);
		centralpanel.add(ConnectButton);
		centralpanel.add(ConnectionResult);
		centralpanel.add(NextButton);
		add(centralpanel);
		NextButton.setEnabled(false);
		
		/* Настройка обработчиков событий кнопок */
		ConnectButton.addActionListener(this);
		NextButton.addActionListener(this);
		
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		
		pack();
		setResizable(false);
		setVisible(true);
		this.requestFocusInWindow();
		
		/* Действия при нажатии на кнопку закрытия окна */
		this.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				db_con.disconnect();
				System.exit(0);
			}
		});
	}
}
