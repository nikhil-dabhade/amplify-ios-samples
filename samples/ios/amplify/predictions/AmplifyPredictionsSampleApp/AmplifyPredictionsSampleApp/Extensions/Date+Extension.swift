//
//  Date+Extension.swift
//  AmplifyPredictionsSampleApp
//
//  Created by Stone, Nicki on 1/15/20.
//  Copyright © 2020 AWS. All rights reserved.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}
