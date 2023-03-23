//
//  AgendaViewController.swift
//  Agenda
//
//  Created by imac on 08/02/23.
//

import UIKit
import EventKit
import Contacts

class AgendaViewController: UIViewController {


    @IBOutlet weak var txfTelefono: UITextField!
    @IBOutlet weak var txfCorreo: UITextField!
    @IBOutlet weak var txvNotas: UILabel!
    
    var nombre:String!
    var lugar:String!
    var fecha:Date!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Nombre: \(nombre!) \nLugar: \(lugar!) \nFecha: \(fecha!)")
    }
    

    @IBAction func regresar() {
        self.dismiss(animated: true)
    }
    

    @IBAction func agendarCita() {
        generarNotificacion()
        agregarEvento()
    }
    
    
    @IBAction func agregarContacto() {
        if validarCorreo(txfCorreo.text!) && txfTelefono.text!.count == 10 {
            agregarContactoApp()
        }
        
        else {
            let alerta = UIAlertController(title: "ERROR", message: "Teléfono o correo inválidos", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alerta.addAction(ok)
            self.present(alerta, animated: true)
        }
    }
    
    @IBAction func ocultarTeclado() {
        view.endEditing(true)
    }
    
    func generarNotificacion() {
        // Genera cuerpo notificación
        let cuerpoNotificacion = UNMutableNotificationContent()
        cuerpoNotificacion.title = "CITA EN UNA HORA"
        cuerpoNotificacion.body = String(format: "Cita con: %@\nLugar cita: %@", nombre!, lugar!)
        cuerpoNotificacion.badge = 1

        // Setear el trigger
        let calendario = Calendar.init(identifier: .gregorian)
        let componentes = calendario.dateComponents([.year, .month, .day, .hour, .minute], from: fecha!.addingTimeInterval(-3600))
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: componentes, repeats: false)
                
        //Solicitar agendar la notificación
        let request = UNNotificationRequest(identifier: "Notificacion", content: cuerpoNotificacion, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func agregarEvento() {
        let evento = EKEventStore()
                
        evento.requestAccess(to: .reminder) { grant, error in
            if grant {
                let recordatorio = EKReminder(eventStore: evento)
                recordatorio.title = String(format: "Cita con: %@", self.nombre!)
                recordatorio.location = self.lugar!
                recordatorio.calendar = evento.defaultCalendarForNewReminders()
                
                DispatchQueue.main.async {
                    recordatorio.notes = self.txvNotas.text!
                }
                        
                let alarma = EKAlarm(absoluteDate: self.fecha!)
                recordatorio.alarms = [alarma]
                
                do {
                    try evento.save(recordatorio, commit: true)
                    
                    DispatchQueue.main.async {
                        let alerta = UIAlertController(title: "EXITO", message: "Evento agendado correctamente en la app de recordatorios", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        alerta.addAction(ok)
                        self.present(alerta, animated: true)
                    }
                    
                }
                
                catch {
                    DispatchQueue.main.async {
                        let alerta = UIAlertController(title: "ERROR", message: "Error", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        alerta.addAction(ok)
                        self.present(alerta, animated: true)
                    }
                }
            }
            else {
                let alerta = UIAlertController(title: "ERROR", message: "La app no tiene permisos", preferredStyle: .actionSheet)
                let ok = UIAlertAction(title: "OK", style: .default)
                alerta.addAction(ok)
                self.present(alerta, animated: true)
                
            }
        }
    }
    
    func validarCorreo(_ email:String)->Bool {
        let expReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", expReg)
                
        return emailPred.evaluate(with: email)
    }
    
    func agregarContactoApp() {
        let contacto = CNMutableContact()
        contacto.givenName = nombre!
        contacto.familyName = "Apellido"
        contacto.organizationName = "UTT"
        
        let telefono = CNLabeledValue.init(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: txfTelefono.text! ))
        contacto.phoneNumbers = [telefono]
        
        let correo = CNLabeledValue(label: CNLabelHome, value: txfCorreo.text! as NSString)
        contacto.emailAddresses = [correo]
        
        let guardarContacto = CNContactStore()
        let peticion = CNSaveRequest()
        
        peticion.add(contacto, toContainerWithIdentifier: nil)
        do {
            try guardarContacto.execute(peticion)
        }
        catch {
            if error.localizedDescription == "Access Denied"
            {
                let alerta = UIAlertController(title: "ERROR", message: "La app no tiene permisos", preferredStyle: .actionSheet)
                let ok = UIAlertAction(title: "OK", style: .default)
                alerta.addAction(ok)
                self.present(alerta, animated: true)
            }
        }
    }
}
