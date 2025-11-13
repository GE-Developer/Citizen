//
//  LetterType.swift
//  Citizen
//
//  Created by GE-Developer
//

enum LetterType: CaseIterable {
    case englishCapitalizedAlphabet
    case georgian
    case eas256
    case binary
    case decimal
    case emoji
    
    var get: [Character] {
        switch self {
        case .englishCapitalizedAlphabet:
            return [
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", 
                "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
                "U", "V", "W", "X", "Y", "Z"
            ]
            
        case .georgian:
            return [
                "ა", "ბ", "გ", "დ", "ე", "ვ", "ზ", "თ", "ი", "კ",
                "ლ", "მ", "ნ", "ო", "პ", "ჟ", "რ", "ს", "ტ", "უ",
                "ფ", "ქ", "ღ", "ყ", "შ", "ჩ", "ც", "ძ", "წ", "ჭ",
                "ხ", "ჯ", "ჰ"
            ]
        case .eas256:
            return Array("!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
        case .binary:
            return ["0", "1"]
        case .decimal:
            return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        case .emoji:
            return [
                "😀", "😳", "😄", "😁", "😆", "🥹", "😅", "😂",
                "🤣", "🥲", "☺️", "😊", "😇", "🙂", "🙃", "😉",
                "😌", "👨‍🦲", "🧑‍🦲", "👩‍🦲", "😗", "😙", "😚", "😋",
                "😛", "😝", "😜", "🤪", "🤓", "😎", "🥸", "🤩",
                "🥳", "🙂‍↕️", "😏", "🙂‍↔️", "🤗", "🤔", "🤭", "🫢",
                "🫡", "🤫", "🤑", "🧔", "🧔‍♂️", "👶", "😺", "😸",
                "😹", "👶🏼", "😼", "😽", "🥺", "🤠", "😴", "🫥",
                "💩", "🧓", "👨", "🧑", "👧", "🧒", "👦", "👩"
            ]
        }
    }
}
