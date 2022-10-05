

import Foundation
//testar error do loadCars
enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalideJson
}

enum RESTOperation {
    case save
    case update
    case delete
}


class REST {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false // não permite usar 4g  caso falso
        config.httpAdditionalHeaders  = ["Content-Type": "application/json"] // recebe e retorno um json/ setado pelo session
        config.timeoutIntervalForRequest = 30.0  // determina que em 30 segundo devo receber uma resposta / else cancela
        config.httpMaximumConnectionsPerHost = 5 // limita a quantidade de acessos ao host
        return config
        
    }()
    
    private static let session = URLSession(configuration: configuration) //URLSession.shared
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError)-> Void) { // alimento cars table com o array de car
        guard let url = URL(string: basePath) else {// desembrulha string pra ler como url
            onError(.url)// testa error de url
            return
        }
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error? )in // cria a tarefa mas n executa
            if error == nil{
                guard let response = response as? HTTPURLResponse else {return}
                if response.statusCode == 200 { // verifica status da request
                    guard let data = data else {
                        onError(.noResponse)// testa erro de response nill
                        return
                    } // desembrulha data
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    }catch {
                        print(error.localizedDescription)
                        onError(.invalideJson)
                    }
                }else{
                    print("Algum status invalido pelo servidor!!")
                    onError(.responseStatusCode(code: response.statusCode))
                }
            } else{
                print(error!)
                onError(.taskError(error: error!))
            }
        }
        dataTask.resume() // trata a informação
    }
    
    
    // metodo para salvar carro (put)
    class func save(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    //adicionar/alterar carro
    class func update(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    
    //deleta/carro
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    // faz o switch para ver qual função deve chamar
    private class func applyOperation(car: Car, operation: RESTOperation ,onComplete: @escaping (Bool) -> Void) {
        
        
        let urlString = basePath + "/" + (car._id ?? "")
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        var httpMethod: String = ""
        var request = URLRequest(url: url)
        
        
        
        switch operation {
         case .save:
            httpMethod = "POSt"
         case .update:
            httpMethod = "PUT"
         case .delete:
            httpMethod = "DELETE"
            
        }
        request.httpMethod = httpMethod
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return        }
        request.httpBody = json
        let dataTask = session.dataTask(with: request) { (data , response, error) in
            if error == nil {
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else {
                    onComplete(false)
                    return
                }
                onComplete(true)
            }else {
                onComplete(false)
            }
        }
        dataTask.resume()

    }
}
