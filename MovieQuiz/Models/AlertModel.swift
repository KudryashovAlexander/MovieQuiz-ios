struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    func completion(_ x:@escaping () -> Void){
        x()
    }
}
