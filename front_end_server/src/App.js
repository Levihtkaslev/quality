import './App.css';
import Qdepartment from './frontend/department';
import Mainform from './frontend/forms';
import Qlocation from './frontend/location';
import Report from './frontend/report';
import Mediadb from './frontend/media';
import Menu from './frontend/menu';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Bounce, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';


function App() {
  return (
  <>
  
  <BrowserRouter>
  <Menu/>

    <ToastContainer theme='dark' position='top-center' autoClose={2000} hideProgressBar={false} newestOnTop={true} closeOnClick transition={Bounce} draggable/>
    <Routes>
      <Route path='/' element={<Mainform/>}/>
      <Route path='/location' element={<Qlocation/>}/>
      <Route path='/department' element={<Qdepartment/>}/>
      <Route path='/report' element={<Report/>}/>
      <Route path='/media' element={<Mediadb/>}/>
    </Routes>
  </BrowserRouter>
 
  </>
  );
}
export default App;
