import { useState, useEffect } from "react";
import * as XLSX from 'xlsx';
import { HiHome } from "react-icons/hi";
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const Report = () => {
    const [loc, setLoc] = useState([]);
    const [depart, setDepart] = useState([]);
    const [choosedLoc, setChoosedLoc] = useState("");
    const [choosedDep, setChoosedDep] = useState("");
    const [filterForm, setFilterForm] = useState([]);
    const [totals, setTotals] = useState({
        totalsubpen: 0,
        totalsubcom: 0,
        totalrecpen: 0,
        totalreccom: 0,
    });

    const backendbaseurl = process.env.REACT_APP_NODE_BACKEND_BASEURL

    // Fetch Locations
    useEffect(() => {
        fetch(`${backendbaseurl}/locations`)
            .then((response) => response.json())
            .then((data) => setLoc(data))
            .catch((err) => console.error("Error on fetching location: ", err));
    }, []);

    // Fetch Departments when Location Changes
    useEffect(() => {
        if (choosedLoc) {
            fetch(`${backendbaseurl}/departments?locationid=${choosedLoc}`)
                .then((response) => response.json())
                .then((data) => setDepart(data))
                .catch((err) => console.error("Error on fetching departments: ", err));
        } else {
            setDepart([]);
        }
    }, [choosedLoc]);

    // Fetch Forms based on Location or Department
    useEffect(() => {
        let query = "";
        if (choosedDep && choosedLoc) {
            query = `locationid=${choosedLoc}&fromdepartment=${choosedDep}&todepartment=${choosedDep}`;
        } else if (choosedLoc) {
            query = `locationid=${choosedLoc}`;
        } else if (choosedDep) {
            query = `fromdepartment=${choosedDep}&todepartment=${choosedDep}`;
        }
    
        if (query) {
            fetch(`${backendbaseurl}/form?${query}`)
                .then((response) => response.json())
                .then((data) => {
                    console.log("Fetched Forms:", data);
                    setFilterForm(data);
                })
                .catch((error) => console.error("Error fetching forms:", error));
        } else {
            setFilterForm([]);
        }
    }, [choosedDep, choosedLoc]);
    

    // Recalculate Totals when Filtered Forms Update
    useEffect(() => {
        const calculateTotals = () => {
            const totals = {
                totalsubpen: 0,
                totalsubcom: 0,
                totalrecpen: 0,
                totalreccom: 0,
            };
    
            filterForm.forEach((form) => {
                if (choosedLoc && form.locationid !== choosedLoc) return;
                if (choosedDep && form.fromdepartment !== choosedDep && form.todepartment !== choosedDep) return;
    
                if (form.status === "Pending" && form.fromdepartment) {
                    totals.totalsubpen += 1;
                }
                if (form.status === "Completed" && form.fromdepartment) {
                    totals.totalsubcom += 1;
                }
                if (form.status === "Pending" && form.todepartment) {
                    totals.totalrecpen += 1;
                }
                if (form.status === "Completed" && form.todepartment) {
                    totals.totalreccom += 1;
                }
            });
    
            setTotals(totals);
        };
    
        calculateTotals();
    }, [filterForm, choosedLoc, choosedDep]);
    

    // Calculate Department Counts
    const calculateCounts = (forms, departmentName) => {
        const pendingSubmitted = forms.filter(
            (form) => form.fromdepartment === departmentName && form.status === "Pending"
        ).length;
        const completedSubmitted = forms.filter(
            (form) => form.fromdepartment === departmentName && form.status === "Completed"
        ).length;
        const pendingReceived = forms.filter(
            (form) => form.todepartment === departmentName && form.status === "Pending"
        ).length;
        const completedReceived = forms.filter(
            (form) => form.todepartment === departmentName && form.status === "Completed"
        ).length;

        return {
            pendingSubmitted,
            completedSubmitted,
            pendingReceived,
            completedReceived,
        };
    };

    const exportToExcel = () => {
        let totalPendingSubmitted = 0;
        let totalCompletedSubmitted = 0;
        let totalPendingReceived = 0;
        let totalCompletedReceived = 0;

        const dataForExport = [];
        depart.filter((dep) => !choosedDep || dep.departmentname === choosedDep)
            .forEach((dep, index) => {
                const depForms = filterForm.filter(
                    (form) =>
                        (choosedLoc ? form.locationid === choosedLoc : true) &&
                        (choosedDep
                            ? form.fromdepartment === dep.departmentname ||
                            form.todepartment === dep.departmentname
                            : true)
                );

                const {
                    pendingSubmitted,
                    completedSubmitted,
                    pendingReceived,
                    completedReceived,
                } = calculateCounts(depForms, dep.departmentname);

                // Accumulate totals
                totalPendingSubmitted += pendingSubmitted;
                totalCompletedSubmitted += completedSubmitted;
                totalPendingReceived += pendingReceived;
                totalCompletedReceived += completedReceived;

                dataForExport.push({
                    "S.No": index + 1,
                    Department: dep.departmentname,
                    "Submitted Pending": pendingSubmitted,
                    "Submitted Completed": completedSubmitted,
                    TotalSubmitted: pendingSubmitted + completedSubmitted,
                    "Received Pending": pendingReceived,
                    "Received Completed": completedReceived,
                    TotalReceived: pendingReceived + completedReceived,
                    "Grand Total": pendingSubmitted + completedSubmitted + pendingReceived + completedReceived,
                });
            });

        // Add the total summary row
        dataForExport.push({
            "S.No": "Total",
            Department: "",
            "Submitted Pending": totalPendingSubmitted,
            "Submitted Completed": totalCompletedSubmitted,
            TotalSubmitted: totalPendingSubmitted + totalCompletedSubmitted,
            "Received Pending": totalPendingReceived,
            "Received Completed": totalCompletedReceived,
            TotalReceived: totalPendingReceived + totalCompletedReceived,
            "Grand Total": totalPendingSubmitted + totalCompletedSubmitted + totalPendingReceived + totalCompletedReceived,
        });

        // Create a worksheet and a workbook
        const ws = XLSX.utils.json_to_sheet(dataForExport);
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Report");

        // Export the workbook to a file
        XLSX.writeFile(wb, "report.xlsx");
        toast.info("Exported successfully");
    };
         


    

    return (
        <div className="outer1box">
            <div className="outerheader">

            <div className="m-11 flex w-full">
                    <div className='flex flex-col gap-2' >
                    <h2 class=" font-semibold text-3xl text-white">Report Page</h2> 
                    <div className="flex items-center space-x-2">
                            <a href="/report" className="text-slate-200 hover:text-white flex items-center">
                                <HiHome className="mr-1" />
                                Home
                            </a>
                            <span className="text-slate-200">/</span>
                            <span className="text-slate-200 hover:text-white">Report</span>
                        </div>
                     </div>

                    <button onClick={exportToExcel} 
                    class="animate-bounce  h-16 drop-shadow-lg shadow-blue-500  text-white bg-blue-500 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-base gap-2 px-5 py-2.5 text-center inline-flex items-center me-2 ml-auto" >
                    Export
                    <svg width="23px" height="23px" viewBox="0 0 24 24" fill="white" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M2 12C2 7.28595 2 4.92893 3.46447 3.46447C4.92893 2 7.28595 2 12 2C16.714 2 19.0711 2 20.5355 3.46447C22 4.92893 22 7.28595 22 12C22 16.714 22 19.0711 20.5355 20.5355C19.0711 22 16.714 22 12 22C7.28595 22 4.92893 22 3.46447 20.5355C2 19.0711 2 16.714 2 12ZM12 6.25C12.4142 6.25 12.75 6.58579 12.75 7V12.1893L14.4697 10.4697C14.7626 10.1768 15.2374 10.1768 15.5303 10.4697C15.8232 10.7626 15.8232 11.2374 15.5303 11.5303L12.5303 14.5303C12.3897 14.671 12.1989 14.75 12 14.75C11.8011 14.75 11.6103 14.671 11.4697 14.5303L8.46967 11.5303C8.17678 11.2374 8.17678 10.7626 8.46967 10.4697C8.76256 10.1768 9.23744 10.1768 9.53033 10.4697L11.25 12.1893V7C11.25 6.58579 11.5858 6.25 12 6.25ZM8 16.25C7.58579 16.25 7.25 16.5858 7.25 17C7.25 17.4142 7.58579 17.75 8 17.75H16C16.4142 17.75 16.75 17.4142 16.75 17C16.75 16.5858 16.4142 16.25 16 16.25H8Z" fill="white"/>
                    </svg>
                    </button>
                </div>
                

            


            
            
            </div>

            <div class=" bg-cyan-100  items-end rounded-lg p-10 gap-6 shadow-lg shadow-teal-200 border hover:bg-cyan-200 transition-all ease-in-out">

            <div className="flex">
            <div class="dropdownone">
            <label class = "dropdownlabel">Choose Location</label>
                <select onChange={(e) => setChoosedLoc(e.target.value)} value={choosedLoc} class="dropdownbutton">
                    <option value="" class="dropdownoption">Select Location </option>
                    {loc.map((loc) => (
                        <option key={loc._id} value={loc._id} class="dropdownoption">
                            {loc.locationname}
                        </option>
                    ))}
                </select>
            </div>


            {depart.length > 0 && (
                <div className="dropdownone">
                    <label class = "dropdownlabel">Select Department (Optional):</label>
                    <select
                        onChange={(e) => setChoosedDep(e.target.value)}
                        value={choosedDep} class="dropdownbutton"
                    >
                        <option value="" class="dropdownoption">All Departments</option>
                        {depart.map((dept) => (
                            <option key={dept._id} value={dept.departmentname} class="dropdownoption">
                                {dept.departmentname}
                            </option>
                        ))}
                    </select>
                </div>
            )}
            </div>



            <div class="tableout">
            {filterForm.length > 0 && (
                
                <table class="table "
                    
                >
                    <thead class= " tablehead">
                        <tr class="px-6 py-3">
                            <th class="tc text-center">S.no</th>
                            <th class="tc">Department</th>
                            <th class="tc">Submitted Pending</th>
                            <th class="tc">Submitted Completed</th>
                            <th class="tc text-center">Total</th>
                            <th class="tc">Received Pending</th>
                            <th class="tc">Received Completed</th>
                            <th class="tc text-center">Total</th>
                            <th class="tc text-center">Grand Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        {depart.filter((dep, index) => !choosedDep || dep.departmentname === choosedDep)
                                .map((dep, index) => {
                                    const depForms = filterForm.filter(
                                        (form) =>
                                            (choosedLoc ? form.locationid === choosedLoc : true) &&
                                            (choosedDep
                                                ? form.fromdepartment === dep.departmentname ||
                                                form.todepartment === dep.departmentname
                                                : true)
                                    );

                                const {
                                    pendingSubmitted,
                                    completedSubmitted,
                                    pendingReceived,
                                    completedReceived,
                                } = calculateCounts(depForms, dep.departmentname);

                                return (
                                    <tr key={dep._id}  class={`h-10 ${index % 2 === 0 ? 'bg-white' : 'bg-gray-100'} hover:bg-gray-300 text-base`}>
                                        <td class="tc bg-slate-700 text-center text-white">{index + 1}</td>
                                        <td class="tc">{dep.departmentname}</td>
                                        <td class="tc">{pendingSubmitted}</td>
                                        <td class="tc">{completedSubmitted}</td>
                                        <td class="tc bg-slate-300 text-center font-bold">{pendingSubmitted + completedSubmitted}</td>
                                        <td class="tc">{pendingReceived}</td>
                                        <td class="tc">{completedReceived}</td>
                                        <td class="tc bg-slate-300 text-center font-bold">{pendingReceived + completedReceived}</td>
                                        <td class="tc bg-slate-700 text-center text-white font-bold hover:bg-white hover:text-black transition-all ease-in-out duration-300">
                                            {pendingSubmitted +
                                                completedSubmitted +
                                                pendingReceived +
                                                completedReceived}
                                        </td>
                                    </tr>
                                );
                            })}
                    </tbody>
                    <tfoot class= " tablefoot">{!choosedDep && 
                        <tr className="font-bold">
                        <td className="tc hover:bg-white hover:text-black" colSpan="2">Total</td>
                        <td className="tc hover:bg-white hover:text-black">{totals.totalsubpen}</td>
                        <td className="tc hover:bg-white hover:text-black">{totals.totalsubcom}</td>
                        <td className="tc text-center hover:bg-white hover:text-black">{totals.totalsubpen + totals.totalsubcom}</td>
                        <td className="tc hover:bg-white hover:text-black">{totals.totalrecpen}</td>
                        <td className="tc hover:bg-white hover:text-black">{totals.totalreccom}</td>
                        <td className="tc hover:bg-white hover:text-black text-center">{totals.totalrecpen + totals.totalreccom}</td>
                        <td className="tc hover:bg-white hover:text-black text-center">
                            {totals.totalsubpen +
                                totals.totalsubcom +
                                totals.totalrecpen +
                                totals.totalreccom}
                        </td>
                    </tr>
                        }
                        
                    </tfoot>
                </table>
                
            )
            }
              <label className="flex justify-center text-gray-400">No More</label>
            </div>
          
        </div>

        </div>
    );
};

export default Report;
