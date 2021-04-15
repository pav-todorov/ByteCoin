import Foundation

protocol CoinManagerDelegate {
    func didFailWithData(error: Error)
    func didUpdateCurrency(currency: CoinModel)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = ""
    
    var delegate:CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                
                if let safeData = data{
                    if let currency = self.parseJSON(safeData){
                        delegate?.didUpdateCurrency(currency: currency)
                    }
                }
                
            }
            task.resume()
        }
    }
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let fiat = decodedData.asset_id_quote

            let coinModel = CoinModel(rate: lastPrice, fiat: fiat)
            //print(lastPrice)
            
            return coinModel
        }catch{
            delegate?.didFailWithData(error: error)
            return nil
        }
    }
    
}
