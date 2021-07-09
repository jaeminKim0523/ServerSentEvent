# ServerSentEvent
Server-Sent-Event 예제 프로젝트

## SSE 간단 설명
인터넷을 하다보면 아래와 같이 화면이 완료되지 않은 상태가 지속되는 경우가 있다.
<img width="75" alt="스크린샷 2021-07-09 오후 11 15 01" src="https://user-images.githubusercontent.com/55477102/125091647-8eb44200-e10b-11eb-8030-d6149336ee9f.png">

이 처럼 로딩 상태를 유지하며 데이터를 지속적으로 받아오는 것이다.

## 내용
### Enum
#### SSEManagerState: SSE의 현재 상태를 나타내기위한 열거형
- connecting: 연결 진행중
- connected: 연결 완료
- disconnected: 연결 종료
- error: 오류

### Protocol
#### SSEManagerDelegate: 현재 세션의 상태 변화를 전달하기 위한 Delegate 패턴
- func sseManager(didChange state: SSEManagerState)

#### SSEManagerDataTaskDelegate: URLSession을 통해 받은 데이터를 전달하기 위한 Delegate 패턴
- @objc optional func sseManager(didReceive error: Error?)
- @objc optional func sseManager(didReceivedData value: Data)
- @objc optional func sseManager(didReceivedString value: String)
- @objc optional func sseManager(didReceivedDictionary value: [String : String])

#### SSEPolicy: SSEManager의 기본 선언 값
- var session: URLSession? { get }
- var dataTask: URLSessionDataTask? { set get }
- var url: URL? { set get }
- var state: SSEManagerState { set get }
- var delegate: SSEManagerDelegate? { set get }
- var dataTaskDelegate: SSEManagerDataTaskDelegate? { set get }

#### extension
- mutating public func setUrl(url: String)
- mutating public func setUrl(url: URL)
- mutating public func connect()
- mutating public func disconnect()

### Class
#### SSEManager
- public override init()
- public init(url: String)
- public init(url: URL)
- private func setSession()
- private func convertDataStringToDictionary(serverSentEventData string: String) -> [String : String]


