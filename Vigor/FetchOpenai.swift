//
//  File.swift
//  Vigor
//
//  Created by Filip Henriksson on 17.02.24.
//
import Foundation

private func fetchValueFromPlist(key: String) -> String? {
       guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
             let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
       else {
           return nil
       }

       return dict[key] as? String
   }
// Add a completion handler parameter to the function
func fetchOpenAIResponse(score: Int, completion: @escaping (String) -> Void) {

    if let apiKey = fetchValueFromPlist(key: "API_KEY") {
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let message = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a the creator behind the app Virgo. This app tracks quantitative measures of user habits such as sleep, gps location and screentime, in order to monitor their mental health. Users will get a score on the app between 0–100 on how good their habits have been in comparison to the previous week. Their score is 60 if there is no change to the previous week, and below 60 if they have had worse habits and above 60 if they have had better habits. Your job is to take in the score of the user and write a 1 sentence descriptor giving them praise if they have improved or supportive suggestions on how to be better, such as socializing or leaving the house more or sleeping more etc if they have performed worse than the previous week. Limit your response to 1-2 sentences"],
                ["role": "user", "content": "Score = \(score)"]
            ]
        ] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON:", error)
            completion("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error making request:", error ?? "Unknown error")
                completion("Error making request: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResult["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion("Failed to parse response.")
                }
            } catch {
                print("Error parsing JSON:", error)
                completion("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}


// Main entry point
// This is usually not needed in an iOS app since you would call fetchOpenAIResponse() from a ViewController or similar.
// For a command line tool or a playground, you can use the following:



// For a playground or a command line tool, make sure the program does not exit before the asynchronous call completes.
// For command line tools, use semaphores, or for Playgrounds, use PlaygroundSupport.
// Example for Playgrounds:
// import PlaygroundSupport
// PlaygroundPage.current.needsIndefiniteExecution = true
