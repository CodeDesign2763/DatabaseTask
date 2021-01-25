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
 
class AuthForm extends JFrame implements ActionListener {
	/* Элементы графического интерфейса */
	private JPanel centralPanel;
	private JTextField userField=new JTextField(30);
	private JPasswordField passwordField=new JPasswordField(30);
	private JTextField dbServerNAField=new JTextField(30);
	private JTextField dbServerPField=new JTextField(30);
	private JButton connectButton = new JButton("Подключиться");
	private JLabel output = new JLabel("Нет подключения");
	private JButton nextButton = new JButton("Далее");
	/* Интерфейс для соединения с БД */
	private DBConnectionIface dbCon=new PGSQLDBConnection();
	/* Указатель на главное окно */
	private MainForm mainFormPointer;
	
	public void setMainFormPointer(MainForm mfp)	{
		this.mainFormPointer=mfp;
	}
	
	public DBConnectionIface get_dbConnection() {
		return this.dbCon;
	}
	
	@Override
	public void actionPerformed(ActionEvent e) {
		if (e.getSource()==connectButton) 
		{
			String pw=new String(passwordField.getPassword());
			
			/* Если данные для подключения верные 
			 * то запомнить их и использовать в дальнейшем
			 * для подключения И разрешить доступ 
			 * к главному окну 
			 */
			if (dbCon.checkConnection(dbServerNAField.getText(),
			dbServerPField.getText(),userField.getText(),
			pw,"admission_office").getResult()) {
				nextButton.setEnabled(true);
				connectButton.setEnabled(false);
				output.setText(
				"Вы успешно подключились к БД!");
			}
			else 
				output.setText(
				"Ошибка при подключении к БД");
			pw="";
		}
		else
		if (e.getSource()==nextButton)  
		{
			mainFormPointer.setVisible(true);
			mainFormPointer.setDBcon(dbCon);
			this.setVisible(false);
			/* Уничтожение формы */
			this.dispose();
		}
	}
	
	public AuthForm(String title) {
		/* Настройка внешнего вида окна */
		setTitle(title);
		centralPanel=new JPanel(new GridLayout(7,1,10,10));
		centralPanel.setBorder(
		BorderFactory.createEmptyBorder(10, 10, 10, 10));
		userField.setBorder(
		BorderFactory.createTitledBorder("Имя пользователя БД"));
		passwordField.setBorder(
		BorderFactory.createTitledBorder("Пароль"));
		dbServerNAField.setBorder(
		BorderFactory.createTitledBorder("Адрес сервера"));
		dbServerPField.setBorder(
		BorderFactory.createTitledBorder("Порт"));
		output.setBorder(
		BorderFactory.createTitledBorder("Результат подключения"));
		centralPanel.add(userField);
		centralPanel.add(passwordField);
		centralPanel.add(dbServerNAField);
		centralPanel.add(dbServerPField);
		centralPanel.add(connectButton);
		centralPanel.add(output);
		centralPanel.add(nextButton);
		add(centralPanel);
		nextButton.setEnabled(false);
		
		/* Настройка обработчиков событий кнопок */
		connectButton.addActionListener(this);
		nextButton.addActionListener(this);
		
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		
		pack();
		setResizable(false);
		setVisible(true);
		this.requestFocusInWindow();
		
		/* Действия при нажатии на кнопку закрытия окна */
		this.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				dbCon.disconnect();
				System.exit(0);
			}
		});
	}
}
