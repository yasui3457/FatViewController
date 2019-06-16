//
//  SearchViewController.swift
//  FatViewController
//
//  Created by 安井陸 on 2019/06/15.
//  Copyright © 2019 安井陸. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultView: UICollectionView!
    
    //QiitaのAPI
    let QIITA_API = "https://qiita.com/api/v2/items?page=1"
    //検索結果を格納する配列
    var resultArray: [Article] = [] {
        didSet {
            searchResultView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSearchBar()
        initializeCollectionView()
    }
    
    func initializeSearchBar() {
        searchBar.delegate = self
    }
    
    func initializeCollectionView() {
        searchResultView.register(UINib(nibName: "SearchResultViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchResultViewCell")
        searchResultView.delegate = self
        searchResultView.dataSource = self
    }
    
    func getArticle() {
        let query = "&query=tag%3A" + searchBar.text!
        let url: URL = URL(string: QIITA_API + query)!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
                DispatchQueue.main.async() { () -> Void in
                    self.resultArray = self.parseToArticle(json: json)
                }
            }
            catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func parseToArticle(json: [Any]) -> [Article] {
        var parseList: [Article] = []
        let datas: [[String: Any]] = json.map { (article) -> [String: Any] in
            return article as! [String: Any]
        }
        for i in 0..<datas.count {
            let data = datas[i]
            var article: Article = Article()
            article.title = data["title"] as? String ?? ""
            article.body = data["body"] as? String ?? ""
            article.url = data["url"] as? String ?? ""
            parseList.append(article)
        }
        return parseList
    }
    
    func moveToBrowserViewController(value: URL) {
        performSegue(withIdentifier: "ToBrowser", sender: value)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToBrowser" {
            guard let bvc:BrowserViewController = segue.destination as? BrowserViewController else { return }
            guard let url: URL = sender as? URL else { return }
            bvc.url = url
        }
    }

}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        getArticle()
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = searchResultView.dequeueReusableCell(withReuseIdentifier: "SearchResultViewCell", for: indexPath) as? SearchResultViewCell else { return UICollectionViewCell() }
        cell.setCellData(article: resultArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        moveToBrowserViewController(value: URL(string: resultArray[indexPath.row].url)!)
    }
    
}
