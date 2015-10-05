//
//  AppViewController.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-09-02.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import DATAStack
import Charts
import Sync
import SwiftyJSON

class AppViewController: UIViewController, ChartViewDelegate {
    @IBOutlet var servicesTableView: UITableView!
    @IBOutlet var instancesTableView: UITableView!
    let dataStack: DATAStack
    var app: CFApp?
    
    required init(coder aDecoder: NSCoder) {
                dataStack = DATAStack(modelName: "CFStore")
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
//        pieChart.delegate = self
//        pieChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: ChartEasingOption.EaseOutBack)
        fetchSummary()
        fetchStats()
    }
    
    func fetchSummary() {
        Alamofire.request(CF.AppSummary(app!.guid))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isFailure) {
                    print(result.value)
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.handleSummaryResponse(result.value!)
                    }
                }
        }
    }
    
    func handleSummaryResponse(data: AnyObject) {
        let predicate = NSPredicate(format: "guid == ''")
        var json = JSON(data)
        Sync.changes(
            [json.object],
            inEntityNamed: "CFApp",
            predicate: predicate,
            dataStack: self.dataStack,
            completion: { error in
                self.setDataCount(json["guid"].stringValue)
            }
        )
    }
    
    func fetchStats() {
        Alamofire.request(CF.AppStats(app!.guid))
            .validate()
            .responseJSON { (_, _, result) in
                if (result.isFailure) {
                    print(result.value)
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        self.handleStatsResponse(result.value!)
                    }
                }
        }
    }
    
    func handleStatsResponse(data: AnyObject) {
//       instancesTableView.delegate = InstancesViewConroller()
        let delegate = instancesTableView.delegate as! InstancesViewConroller
        delegate.instances = JSON(data)
        dispatch_async(dispatch_get_main_queue(), {
            self.instancesTableView.reloadData()
            let height = self.instancesTableView.contentSize.height

//            [UIView animateWithDuration:0.25 animations:^{
            var frame = self.instancesTableView.frame
            frame.size.height = height
            self.instancesTableView.frame = frame;
            
            // if you have other controls that should be resized/moved to accommodate
            // the resized tableview, do that here, too
//            }];
        });

    }
    
    func setDataCount(guid: String) {
//        let request = NSFetchRequest(entityName: "CFApp")
//        let predicate = NSPredicate(format: "guid == %@", guid)
//        request.predicate = predicate
//        
//        do {
//            let apps = try dataStack.mainContext.executeFetchRequest(request) as! [CFApp]
//            self.app = apps[0]
//        } catch {
//            self.app = nil
//        }
//        
//        let runningData = ChartDataEntry(value: Double(app!.runningInstanceCount), xIndex: 0)
//        let notRunningData = ChartDataEntry(value: Double(app!.stoppedInstanceCount()), xIndex: 1)
//        let chartDataSet = PieChartDataSet(yVals: [runningData, notRunningData], label: "")
//        
//        let colors = [
//                UIColor(red: 1/255.0, green: 255/255.0, blue: 1/255.0, alpha: 0.8),
//                UIColor(red: 255/255.0, green: 1/255.0, blue: 1/255.0, alpha: 0.8)
//            ]
//        chartDataSet.colors = colors
//        
//        let pFormatter = NSNumberFormatter()
//        pFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
//        pFormatter.maximumFractionDigits = 1;
//        pFormatter.multiplier = 1
//        pFormatter.percentSymbol = " %";
//        let data = PieChartData(xVals: ["Running", "Stopped"], dataSet: chartDataSet)
////        data.addDataSet(notRunningDataSet)
//        data.setValueFormatter(pFormatter)
//        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 11))
//        
//        pieChart.data = data
    }
}