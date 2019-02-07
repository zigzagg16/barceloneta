import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var barcelonetaView: Barceloneta!
    @IBOutlet weak var bcnViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bcnViewHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        barcelonetaView.layer.cornerRadius = 25
        enableBarceloneta(.vertical)
    }

    override func viewWillAppear(_ animated: Bool) {
        //Set the default background color
        self.barcelonetaView.backgroundColor = color(forMinimalRange: 0)
        barcelonetaDidChangeValue(barcelonetaView, value: 0)
    }

    // MARK: - Settings
    @IBAction func changedAxis(_ sender: UISegmentedControl) {
        enableBarceloneta(sender.selectedSegmentIndex == 0 ? .vertical : .horizontal)
    }

    @IBAction func changedLooping(_ sender: UISwitch) {
        barcelonetaView.loops = sender.isOn
    }

    private func enableBarceloneta(_ axis: Axis) {
        let timerSettings = [
            (range: 0..<70, timer: 0.3, increment: 1.0),
            (range: 70..<120, timer: 0.2, increment: 2.0),
            (range: 120..<500, timer: 0.1, increment: 3.0)
        ]
        barcelonetaView.makeElastic(timerSettings: timerSettings,
                                    constraint:
            axis == .horizontal ? bcnViewHorizontalConstraint : bcnViewVerticalConstraint,
                                    axis: axis,
                                    delegate: self)
        infoLabel.text = "Drag this view \n\(axis == .vertical ? "⇡ or ⇣" : "⇠ or ⇢")\nto change the value"
    }
}

// MARK: - BarcelonetaDelegate
extension ViewController: BarcelonetaDelegate {

    func barcelonetaDidStartMoving(_ view: Barceloneta) {}

    func barcelonetaDidChangeValue(_ view: Barceloneta, value: Double) {
        valueLabel.text = "\(Int(value))"
    }

    func barcelonetaDidRelease(_ view: Barceloneta) {
        //the user released la barceloneta
        //Resset to default color
        self.barcelonetaView.backgroundColor = color(forMinimalRange: 0)
    }

    func barcelonetaDidReachNewTimerSetting(_ view: Barceloneta, setting: TimerSetting) {
        self.barcelonetaView.backgroundColor = color(forMinimalRange: setting.range.startIndex)
    }

    ///Color for a minimal range
    fileprivate func color(forMinimalRange range: Int) -> UIColor {
        switch range {
        case 70:
            return UIColor(red: 1.00, green: 0.66, blue: 0.16, alpha: 1.00) //Orange
        case 120:
            return UIColor(red: 0.90, green: 0.31, blue: 0.26, alpha: 1.00) //Red
        default:
            return UIColor(red: 0.22, green: 0.80, blue: 0.46, alpha: 1.00) //Green
        }
    }
}
