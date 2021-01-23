/*
 * Учебное задание по дисциплине БД
 * Программа для взаимодействия с БД из ЛР5
 * 
 * Класс SpecialityForm
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
import javax.swing.event.ListSelectionListener;
import javax.swing.event.ListSelectionEvent;
 
class SpecialityForm extends JFrame 
implements ActionListener, db_proc_iface, ListSelectionListener
{
	private JPanel centralpanel;
	private JPanel horpanel1;
	private JPanel horpanel2;
	private JPanel verpanel1;
	private DefaultListModel<String> SpecListData=
	new DefaultListModel<String>();
	
	private JList<String> SpecList = new JList<String>(SpecListData);
	private JButton AddButton = new JButton("Добавить");
	private JButton ChangeButton = new JButton("Изменить");
	private JButton DeleteButton = new JButton("Удалить");
	private JButton OKButton= new JButton("ОК");;
	
	private DefaultComboBoxModel<String> SubjListData=
	new DefaultComboBoxModel<String>();
	private JComboBox<String> SubjList=
	new JComboBox<String>(SubjListData);
	
	private JTextField SpecName=new JTextField(50);
	private JTextField SpecCode=new JTextField(10);
	private JTextArea Output= new JTextArea();
	private JScrollPane SpecListScroll;
	private db_connection_iface db_con;
	
	public void valueChanged(ListSelectionEvent e) {
		/* Обязательно нужно делать проверку getSelectedValue()!=null
		 * если в дальнейшем используется метод toString()
		 * иначе может быть nullpointexception
		 */
		if ((e.getSource()==SpecList) 
		&& (SpecList.getSelectedValue()!=null))
		{
			SpecCode.setText(SpecList.getSelectedValue());
			SpecName.setText(db_con.sql_function_single(
			"SELECT name FROM speciality WHERE speciality_code='"
			+SpecList.getSelectedValue().toString().trim()
			+"';","name").get_string());
			SubjList.setSelectedItem(db_con.sql_function_single(
			"select subject.name from speciality join subject"
			+" on subject.id=speciality.subject_vips "
			+"where speciality.speciality_code='"
			+SpecList.getSelectedValue().toString().trim()
			+"';","name").get_string());
			ChangeButton.setEnabled(true);
			DeleteButton.setEnabled(true);
		}
    }
	
	public void setDBcon(db_connection_iface dbc)
	{
		this.db_con=dbc;
	} 
	
	public void reset() {
		SpecList.clearSelection();
		SpecList.setEnabled(false);
		SpecListData.removeAllElements();
		String[] atr_array={"speciality_code"};
		query_result qr1;
		qr1=db_con.sql_function("select * from speciality;",
		atr_array);
		
		fill_list_w_qr(qr1,SpecListData);
		if (qr1.get_result()) 
			Output.setText(
			"Чтение БД успешно (список НП)"+"\n"+Output.getText());
		else
			Output.setText(
			"Ошибка при чтении БД (список НП)"+"\n"+Output.getText());
		
		fill_combobox_w_qr(db_con.sql_function_single(
		"select distinct subject.name from speciality"
		+" join subject on subject.id=speciality.subject_vips;",
		"name"),SubjListData);
		
		SpecName.setText("");
		SpecName.setEnabled(false);
		SpecCode.setText("");
		SpecCode.setEnabled(false);
		SubjList.setEnabled(false);
		SubjList.setSelectedItem("");
		OKButton.setEnabled(false);
		SpecList.setEnabled(true);
		
	}
	
	@Override
	public void actionPerformed(ActionEvent e)
	{
		if (e.getSource()==AddButton)
		{
			reset();
			
			SpecCode.setEnabled(true);
			OKButton.setEnabled(true);
			SubjList.setEnabled(true);
			SpecName.setEnabled(true);
			OKButton.setActionCommand("add");
			
			AddButton.setEnabled(false);
			ChangeButton.setEnabled(false);
			DeleteButton.setEnabled(false);
			
		}
		if (e.getSource()==ChangeButton)
		{
			
			SpecCode.setEnabled(true);
			OKButton.setEnabled(true);
			SubjList.setEnabled(true);
			SpecName.setEnabled(true);
			OKButton.setActionCommand("change");
			
			AddButton.setEnabled(false);
			ChangeButton.setEnabled(false);
			DeleteButton.setEnabled(false);
		}
		if (e.getSource()==DeleteButton)
		{
			
			OKButton.setEnabled(true);
			OKButton.setActionCommand("delete");
			
			AddButton.setEnabled(false);
			ChangeButton.setEnabled(false);
			DeleteButton.setEnabled(false);
		}
		if (e.getSource()==OKButton)
		{
			if (e.getActionCommand().equals("add"))
			{
				query_result qr_id =
				db_con.sql_function_single(
				"select id from subject where subject.name='"
				+SubjList.getSelectedItem().toString()+"';","id");
				Output.setText("insert into speciality values('"
				+SpecCode.getText()+"',"+qr_id.get_string()
				+",'"+SpecName.getText()+"');");
				
				if (db_con.sql_procedure(
				"insert into speciality values('"
				+SpecCode.getText()+"',"+qr_id.get_string()
				+",'"+SpecName.getText()+"');"))
					Output.setText("Запись успешно добавлена\n"
					+Output.getText());
				else 
					Output.setText(
					"Ошибка при добавлении записи\n"
					+Output.getText());
				
				OKButton.setEnabled(false);
				SpecName.setEnabled(false);
				SpecCode.setEnabled(false);
				SubjList.setEnabled(false);
				ChangeButton.setEnabled(false);
				DeleteButton.setEnabled(false);
				reset();
			}
			if (e.getActionCommand().equals("change") 
			&& (SpecList.getSelectedValue()!=null))
			{
				if (db_con.sql_procedure(
				"delete from speciality where speciality_code='"
				+SpecList.getSelectedValue().toString().trim()+"';"))
					Output.setText("Запись успешно удалена\n"
					+Output.getText());
				else
					Output.setText(
					"Ошибка при удалении записи\n"
					+Output.getText());
				
					//Output.setText("\n"+Output.getText());
				
				query_result qr_id =
				db_con.sql_function_single(
				"select id from subject where subject.name='"
				+SubjList.getSelectedItem().toString()+"';","id");
				
				if (db_con.sql_procedure(
				"insert into speciality values('"
				+SpecCode.getText().trim()+"',"+qr_id.get_string()
				+",'"+SpecName.getText()+"');"))
					Output.setText("Запись успешно добавлена\n"
					+Output.getText());
				else 
					Output.setText(
					"Ошибка при добавлении записи\n"
					+Output.getText());
				OKButton.setEnabled(false);
				SpecName.setEnabled(false);
				SpecCode.setEnabled(false);
				SubjList.setEnabled(false);
				ChangeButton.setEnabled(false);
				DeleteButton.setEnabled(false);
				reset();
			}
			
			if (e.getActionCommand().equals("delete") 
			&& (SpecList.getSelectedValue()!=null))
			{
				Output.setText(
				"delete from speciality where speciality_code='"
				+SpecList.getSelectedValue().toString().trim()+"';");
					Output.setText("Запись успешно удалена\n"
					+Output.getText());
				if (db_con.sql_procedure(
				"delete from speciality where speciality_code='"
				+SpecList.getSelectedValue().toString().trim()+"';"))
					Output.setText("Запись успешно удалена\n"
					+Output.getText());
				else
					Output.setText(
					"Ошибка при удалении записи\n"
					+Output.getText());
				
				OKButton.setEnabled(false);
				SpecName.setEnabled(false);
				SpecCode.setEnabled(false);
				SubjList.setEnabled(false);
				ChangeButton.setEnabled(false);
				DeleteButton.setEnabled(false);
				reset();
			}
			AddButton.setEnabled(true);
		}
	}
	
	public SpecialityForm(String title, db_connection_iface dbc)
	{
		//Configuring the graphical interface
		db_con=dbc;
		setTitle(title);
		centralpanel=new JPanel();
		centralpanel.setLayout(new BoxLayout(centralpanel,
		BoxLayout.Y_AXIS));
		horpanel1=new JPanel(new FlowLayout());
		verpanel1=new JPanel(new GridLayout(3,1,10,10));
		horpanel2=new JPanel(new FlowLayout());
		/* horpanel1 */
		
		SpecListScroll=new JScrollPane(SpecList);
		SpecListScroll.setPreferredSize(new Dimension(300, 200));
		
		horpanel1.add(SpecListScroll);
		/* verpanel1 */
		SpecName.setBorder(
		BorderFactory.createTitledBorder("Название НП"));
		verpanel1.add(SpecName);
		SubjList.setBorder(
		BorderFactory.createTitledBorder("Предмет ВИПС"));
		verpanel1.add(SubjList);
		SpecCode.setBorder(
		BorderFactory.createTitledBorder("Код НП"));
		
		verpanel1.add(SpecCode);
		
		horpanel1.add(verpanel1);
		centralpanel.add(horpanel1);
		
		/* horpanel2 */
		horpanel2.add(AddButton);
		//AddButton.setPreferredSize(new Dimension(10,10));
		horpanel2.add(ChangeButton);
		horpanel2.add(DeleteButton);
		horpanel2.add(OKButton);
		centralpanel.add(horpanel2);
		/* output */
		Output.setBorder(
		BorderFactory.createTitledBorder("Результат операций"));
		centralpanel.add(Output);
		Output.setPreferredSize(new Dimension(200,100));
		centralpanel.setBorder(
		BorderFactory.createEmptyBorder(10,10,10,10));
		
		add(centralpanel);
    
    	SpecList.addListSelectionListener(this);
    	AddButton.addActionListener(this);
    	OKButton.addActionListener(this);
    	ChangeButton.addActionListener(this);
    	DeleteButton.addActionListener(this);

		
		//Picture for the dialog box
		//win_icon = new ImageIcon("win.png");
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		pack();
		setResizable(false);
		setVisible(false);
		//checkanswer.requestFocus();
		this.requestFocusInWindow();
		
		this.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				SpecList.clearSelection();
				setVisible(false);
			}
		});
	}
}
