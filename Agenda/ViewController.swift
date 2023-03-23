//
//  ViewController.swift
//  Agenda
//
//  Created by imac on 08/02/23.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var txfLugar: UITextField!
    @IBOutlet weak var dpkFecha: UIDatePicker!
    @IBOutlet weak var btnSiguiente: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dpkFecha.minimumDate = Date.init().addingTimeInterval(1800)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AgendaViewController
        vc.nombre = txfNombre.text
        vc.lugar = txfLugar.text
        vc.fecha = dpkFecha.date
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfNombre {
            txfLugar.becomeFirstResponder()
        }
        
        else {
            txfLugar.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if txfNombre.text!.count > 1 && txfLugar.text!.count > 1{
            btnSiguiente.isEnabled = true
        }
        
        else {
            btnSiguiente.isEnabled = false
        }
    }

}

